import Foundation

struct KeychainClient {
    let get: (Item) throws -> [QueryResult]

    let setValueForItem: (Item.Value, Item) throws -> Void

    let removeItem: (Item) throws -> Void

    init(
        get: @escaping (Item) throws -> [QueryResult],
        setValueForItem: @escaping (Item.Value, Item) throws -> Void,
        removeItem: @escaping (Item) throws -> Void
    ) {
        self.get = get
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
    }
}

// String convenience methods
extension KeychainClient {
    func get(_ item: Item) throws -> String? {
        try get(item)
            .first
            .flatMap { String(data: $0.data, encoding: .utf8) }
    }

    func set(_ value: String, for item: Item) throws {
        try setValueForItem(
            .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessPolicy: nil, syncingBehavior: .disabled),
            item
        )
    }
}

// Private key registration convenience methods
extension KeychainClient {
    func set(
        key: Data,
        registration: KeyRegistration,
        accessPolicy: Item.AccessPolicy,
        syncingBehavior: Item.SyncingBehavior
    ) throws {
        try setValueForItem(
            .init(
                data: key,
                account: registration.userId,
                label: registration.userLabel,
                generic: Current.jsonEncoder.encode(registration),
                accessPolicy: accessPolicy,
                syncingBehavior: syncingBehavior
            ),
            .privateKeyRegistration
        )
    }
}

extension KeychainClient {
    struct QueryResult {
        let data: Data
        let createdAt: Date
        let modifiedAt: Date
        let label: String?
        let account: String
        let generic: Data?
    }

    struct KeyRegistration: Codable {
        let userId: String
        let userLabel: String
        let registrationId: String
    }

    enum KeychainError: Swift.Error {
        case resultMissingAccount
        case resultMissingDates
        case resultNotArray
        case resultNotData
        case unableToCreateAccessControl
        case unhandledError(status: OSStatus)
    }
}

extension KeychainClient.Item {
    static let stytchEMLPKCECodeVerifier: Self = .init(kind: .token, name: "stytch_eml_pkce_code_verifier")
    static let stytchPWResetByEmailPKCECodeVerifier: Self = .init(kind: .token, name: "stytch_password_reset_by_email_pkce_code_verifier")
}