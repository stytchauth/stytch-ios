import Foundation

/// Client-derived information about the authenticator that created a passkey, parsed from the
/// WebAuthn attestation object during the registration ceremony.
///
/// Stytch's API does not store or return any of these values, so they are only available at the
/// moment of registration — capture them then (e.g. to derive a user-facing passkey name).
public struct PasskeyAuthenticatorInfo: Codable, Sendable, Equatable {
    /// The AAGUID identifying the passkey provider which created and stores the credential
    /// (e.g. iCloud Keychain, Google Password Manager, 1Password). `nil` when the authenticator
    /// did not include one. Resolve it to a display name using the community-sourced list at
    /// https://github.com/passkeydeveloper/passkey-authenticator-aaguids
    public let aaguid: UUID?

    /// Whether the credential is eligible for backup — the WebAuthn `BE` flag.
    public let isBackupEligible: Bool

    /// Whether the credential is currently backed up (synced across devices) — the WebAuthn `BS` flag.
    public let isBackedUp: Bool

    public init(aaguid: UUID?, isBackupEligible: Bool, isBackedUp: Bool) {
        self.aaguid = aaguid
        self.isBackupEligible = isBackupEligible
        self.isBackedUp = isBackedUp
    }
}

extension PasskeyAuthenticatorInfo {
    /// Parses authenticator information from a CBOR-encoded WebAuthn attestation object, returning
    /// `nil` when the data is not a well-formed attestation object.
    init?(attestationObject: Data) {
        guard let authenticatorData = Self.authenticatorData(fromAttestationObject: attestationObject) else {
            return nil
        }
        self.init(authenticatorData: authenticatorData)
    }

    /// Parses authenticator information from WebAuthn authenticator data, which is laid out as:
    /// rpIdHash (32 bytes), flags (1 byte), signCount (4 bytes), then — only when the AT flag is
    /// set — attested credential data, which begins with the 16-byte AAGUID.
    init?(authenticatorData: Data) {
        let bytes = [UInt8](authenticatorData)
        let flagsIndex = 32
        guard bytes.count > flagsIndex else {
            return nil
        }
        let flags = bytes[flagsIndex]
        let isBackupEligible = flags & 0b0000_1000 != 0
        let isBackedUp = flags & 0b0001_0000 != 0
        let attestedCredentialDataIncluded = flags & 0b0100_0000 != 0

        var aaguid: UUID?
        let aaguidRange = 37..<53
        if attestedCredentialDataIncluded, bytes.count >= aaguidRange.upperBound {
            let aaguidBytes = Array(bytes[aaguidRange])
            // An all-zero AAGUID means the authenticator declined to identify itself.
            if aaguidBytes.contains(where: { byte in byte != 0 }) {
                aaguid = .init(uuid: (
                    aaguidBytes[0], aaguidBytes[1], aaguidBytes[2], aaguidBytes[3],
                    aaguidBytes[4], aaguidBytes[5], aaguidBytes[6], aaguidBytes[7],
                    aaguidBytes[8], aaguidBytes[9], aaguidBytes[10], aaguidBytes[11],
                    aaguidBytes[12], aaguidBytes[13], aaguidBytes[14], aaguidBytes[15]
                ))
            }
        }

        self.init(aaguid: aaguid, isBackupEligible: isBackupEligible, isBackedUp: isBackedUp)
    }

    /// Extracts the `authData` byte string from an attestation object's top-level CBOR map
    /// (`{ fmt, attStmt, authData }`). Supports only the definite-length encodings CTAP2 requires.
    private static func authenticatorData(fromAttestationObject attestationObject: Data) -> Data? {
        var reader = CBORReader(bytes: [UInt8](attestationObject))
        guard let mapHeader = reader.readHeader(), mapHeader.majorType == .map else {
            return nil
        }
        for _ in 0..<mapHeader.itemValue {
            guard let keyHeader = reader.readHeader() else {
                return nil
            }
            var isAuthDataKey = false
            if keyHeader.majorType == .textString {
                guard let keyBytes = reader.readBytes(count: keyHeader.itemValue) else {
                    return nil
                }
                isAuthDataKey = String(decoding: keyBytes, as: UTF8.self) == "authData"
            } else {
                guard reader.skipBody(of: keyHeader) else {
                    return nil
                }
            }
            if isAuthDataKey {
                guard
                    let valueHeader = reader.readHeader(),
                    valueHeader.majorType == .byteString,
                    let valueBytes = reader.readBytes(count: valueHeader.itemValue)
                else {
                    return nil
                }
                return Data(valueBytes)
            }
            guard reader.skipItem() else {
                return nil
            }
        }
        return nil
    }
}

/// A minimal CBOR reader supporting just enough of RFC 8949 to walk a WebAuthn attestation
/// object: definite-length items only, as mandated by CTAP2's canonical encoding rules.
private struct CBORReader {
    enum MajorType: UInt8 {
        case unsigned = 0
        case negative = 1
        case byteString = 2
        case textString = 3
        case array = 4
        case map = 5
        case tag = 6
        case simple = 7
    }

    struct Header {
        let majorType: MajorType
        /// The item's inline value: the integer value, string/collection length, or tag number.
        let itemValue: UInt64
    }

    private let bytes: [UInt8]
    private var index = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    mutating func readHeader() -> Header? {
        guard index < bytes.count else {
            return nil
        }
        let initialByte = bytes[index]
        index += 1
        guard let majorType = MajorType(rawValue: initialByte >> 5) else {
            return nil
        }
        let additionalInfo = initialByte & 0b0001_1111
        switch additionalInfo {
        case 0...23:
            return Header(majorType: majorType, itemValue: UInt64(additionalInfo))
        case 24...27:
            let followingByteCount = 1 << (additionalInfo - 24)
            guard let valueBytes = readBytes(count: UInt64(followingByteCount)) else {
                return nil
            }
            let itemValue = valueBytes.reduce(UInt64(0)) { partialValue, byte in
                partialValue << 8 | UInt64(byte)
            }
            return Header(majorType: majorType, itemValue: itemValue)
        default:
            // 28-30 are reserved and 31 (indefinite length) is forbidden by CTAP2 canonical encoding.
            return nil
        }
    }

    mutating func readBytes(count: UInt64) -> [UInt8]? {
        guard count <= UInt64(bytes.count - index) else {
            return nil
        }
        let range = index..<(index + Int(count))
        index = range.upperBound
        return Array(bytes[range])
    }

    mutating func skipItem() -> Bool {
        guard let header = readHeader() else {
            return false
        }
        return skipBody(of: header)
    }

    mutating func skipBody(of header: Header) -> Bool {
        switch header.majorType {
        case .unsigned, .negative, .simple:
            // Any following value bytes (e.g. float payloads) were already consumed by readHeader.
            return true
        case .byteString, .textString:
            return readBytes(count: header.itemValue) != nil
        case .array:
            for _ in 0..<header.itemValue {
                guard skipItem() else {
                    return false
                }
            }
            return true
        case .map:
            for _ in 0..<header.itemValue {
                guard skipItem(), skipItem() else {
                    return false
                }
            }
            return true
        case .tag:
            return skipItem()
        }
    }
}
