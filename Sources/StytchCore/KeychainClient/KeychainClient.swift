import Foundation

struct KeychainClient {
    private let getItem: (Item) throws -> String?

    private let setValueForItem: (Self, String, Item) throws -> Void

    private let removeItem: (Self, Item) throws -> Void

    private let resultExists: (Item) -> Bool

    private let publicKeyForItem: (Self, Item) throws -> PublicKey?

    let fetchKeyForItem: (Item, KeyClass) throws -> SecKey?

    private let signChallenge: (Self, String, Item, String) throws -> String

    init(
        getItem: @escaping (Item) throws -> String?,
        setValueForItem: @escaping (Self, String, Item) throws -> Void,
        removeItem: @escaping (Self, Item) throws -> Void,
        resultExists: @escaping (Item) -> Bool,
        publicKeyForItem: @escaping (Self, Item) throws -> PublicKey?,
        fetchKeyForItem: @escaping (Item, KeyClass) throws -> SecKey?,
        signChallenge: @escaping (Self, String, Item, String) throws -> String
    ) {
        self.getItem = getItem
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
        self.resultExists = resultExists
        self.publicKeyForItem = publicKeyForItem
        self.fetchKeyForItem = fetchKeyForItem
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

    func publicKey(for item: Item) throws -> PublicKey? {
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

            return baseQuery
                .merging(getQuerySegment) { $1 } as CFDictionary
        }

        func insertQuery(value: String) -> CFDictionary {
            baseQuery.merging(querySegmentForUpdate(for: value)) { $1 } as CFDictionary
        }

        func querySegmentForUpdate(for value: String) -> [CFString: Any] {
            [kSecValueData: Data(value.utf8)]
        }

        func createKeyPairQuery(accessControl: SecAccessControl) -> CFDictionary {
            baseQuery.merging([
                kSecAttrKeySizeInBits: 2048, // TODO: - confirm key size
                kSecAttrIsPermanent: true,
                kSecPublicKeyAttrs: [
                    kSecAttrApplicationTag: KeyClass.public.rawValue,
                ],
                kSecPrivateKeyAttrs: [
                    kSecAttrApplicationTag: KeyClass.private.rawValue,
                    kSecAttrAccessControl: accessControl, // FIXME: - messed up on ios 15 simulator
                ],
            ]) { $1 } as CFDictionary
        }

        func getKeyPairQuery(keyClass: KeyClass) -> CFDictionary {
            baseQuery.merging([kSecAttrApplicationTag: keyClass.rawValue]) { $1 } as CFDictionary
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
    public struct PublicKey {
        public let base64Encoded: String
        let secKey: SecKey

        public init(rawValue: String) throws {
            let options: [CFString: Any] = [
                kSecAttrKeyType: KeychainClient.Item.Kind.keyPairKeyType,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
            ]

            var error: Unmanaged<CFError>?

            guard let secKey = SecKeyCreateWithData(Data(rawValue.utf8) as CFData, options as CFDictionary, &error) else {
                throw error.toError() ?? KeychainError.keyCreationFromExternalDataFailed
            }

            base64Encoded = rawValue
            self.secKey = secKey
        }

        public init(_ publicKey: SecKey) throws {
            var error: Unmanaged<CFError>?

            guard let externalRepresentationData = SecKeyCopyExternalRepresentation(publicKey, &error) as? Data else {
                throw error.toError() ?? KeychainError.publicKeyExternalRepresentationCreationFailed
            }

            base64Encoded = externalRepresentationData.base64EncodedString()
            secKey = publicKey
        }
    }

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

    enum KeyClass: String {
        case `private`
        case `public`
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
