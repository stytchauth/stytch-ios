import Foundation

struct KeychainClient {
    private let getItem: (Item) throws -> String?

    private let setValueForItem: (Self, String, Item) throws -> Void

    private let removeItem: (Self, Item) throws -> Void

    private let resultExists: (Item) -> Bool

    private let publicKeyForItem: (Self, Item) throws -> String

    let privateKeyForItem: (Item) throws -> SecKey?

    private let signChallenge: (Self, String, Item, String) throws -> String

    init(
        getItem: @escaping (Item) throws -> String?,
        setValueForItem: @escaping (Self, String, Item) throws -> Void,
        removeItem: @escaping (Self, Item) throws -> Void,
        resultExists: @escaping (Item) -> Bool,
        publicKeyForItem: @escaping (Self, Item) throws -> String,
        privateKeyForItem: @escaping (Item) throws -> SecKey?,
        signChallenge: @escaping (Self, String, Item, String) throws -> String
    ) {
        self.getItem = getItem
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
        self.resultExists = resultExists
        self.publicKeyForItem = publicKeyForItem
        self.privateKeyForItem = privateKeyForItem
        self.signChallenge = signChallenge
    }

    func get(_ item: Item) throws -> String? {
        try getItem(item)
    }

    func set(_ value: String, for item: Item) throws {
        try setValueForItem(self, value, item)
    }

    func remove(_ item: Item) throws {
        try removeItem(self, item)
    }

    func resultExists(for item: Item) -> Bool {
        resultExists(item)
    }

    func publicKey(for item: Item) throws -> String {
        try publicKeyForItem(self, item)
    }

    func sign(challenge: String, for item: Item, using algorithm: String) throws -> String {
        try signChallenge(self, challenge, item, algorithm)
    }
}

extension KeychainClient {
    struct Item {
        enum Kind {
            case token
            case keyPair(AppStatusOption)

            var keyType: CFString? {
                switch self {
                case .token:
                    return nil
                case .keyPair:
                    return Self.keyPairKeyType
                }
            }

            static let keyPairKeyType: CFString = kSecAttrKeyTypeEC // TODO: confirm this vs ECPrimeRandom
        }

        var kind: Kind

        var name: String

        var baseQuery: [CFString: Any] {
            var query: [CFString: Any] = [
                kSecClass: secClass,
                kSecAttrAccount: name,
                kSecAttrApplicationLabel: Bundle.main.bundleIdentifier ?? "com.stytch.StytchCore", // FIXME: - confirm this is desired/handles app groups
            ]
            if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
                query[kSecUseDataProtectionKeychain] = true
            }
            if let keyType = kind.keyType {
                query[kSecAttrKeyType] = keyType
            }
            // TODO: - add syncronizable
            return query
        }

        var getQuery: CFDictionary {
            let getQuerySegment: [CFString: Any]

            switch kind {
            case .token:
                getQuerySegment = [
                    kSecReturnData: true,
                    kSecMatchLimit: kSecMatchLimitOne,
                ]
            case .keyPair:
                getQuerySegment = [kSecReturnRef: true]
            }

            return baseQuery.merging(getQuerySegment)
        }

        func insertQuery(value: String) -> CFDictionary {
            baseQuery.merging(querySegmentForUpdate(for: value))
        }

        func querySegmentForUpdate(for value: String) -> [CFString: Any] {
            [kSecValueData: Data(value.utf8)]
        }

        func createKeyPairQuery(accessControl: SecAccessControl) -> CFDictionary {
            baseQuery.merging([
                kSecAttrKeySizeInBits: 2048, // TODO: - confirm key size
                kSecPublicKeyAttrs: [:],
                kSecPrivateKeyAttrs: [
                    kSecAttrIsPermanent: true,
                    kSecAttrAccessControl: accessControl, // FIXME: - messed up on ios 15 simulator
                ],
            ])
        }

        var privateKeyQuery: CFDictionary {
            baseQuery as CFDictionary
        }

        private var secClass: CFString {
            switch kind {
            case .token:
                return kSecClassGenericPassword
            case .keyPair:
                return kSecClassKey
            }
        }
    }

    enum KeychainError: Swift.Error {
        case accessControlCreationFailed
        case challengeSigningFailed
        case keyCreationFromExternalDataFailed
        case keychainItemKindMistmatch
        case notSecKey
        case noPrivateKeyFound
        case privateKeyGenerationFailed
        case publicKeyExternalRepresentationCreationFailed
        case publicKeyGenerationFailed
        case resultNotData
        case signingNotSupportedWithAlgorithm(String)
        case unhandledError(status: OSStatus)
    }
}

extension KeychainClient {
    // TODO: remove this for better
    public enum AppStatusOption {
        case foreground
        case background

        var value: CFString {
            switch self {
            case .background:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .foreground:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            }
        }
    }
}

extension Optional where Wrapped == Unmanaged<CFError> {
    func throwIfPresent() throws {
        try map { throw $0.asError }
    }

    func toError() -> Error? {
        self?.asError
    }
}

extension Unmanaged where Instance == CFError {
    var asError: Error {
        takeRetainedValue() as Error
    }
}

extension KeychainClient.Item {
    static let stytchPKCECodeVerifier: Self = .init(kind: .token, name: "stytch_pkce_code_verifier")
}

extension Dictionary where Key == CFString, Value == Any {
    func merging(_ other: Self) -> CFDictionary {
        self.merging(other) { $1 } as CFDictionary
    }
}
