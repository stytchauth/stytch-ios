import Foundation

struct KeychainClient {
    let get: (Item) throws -> [QueryResult]

    let valueExistsForItem: (Item) -> Bool

    let setValueForItem: (Item.Value, Item) throws -> Void

    let removeItem: (Item) throws -> Void

    @Dependency(\.jsonEncoder) var jsonEncoder
    @Dependency(\.jsonDecoder) var jsonDecoder

    init(
        get: @escaping (Item) throws -> [QueryResult],
        valueExistsForItem: @escaping (Item) -> Bool,
        setValueForItem: @escaping (Item.Value, Item) throws -> Void,
        removeItem: @escaping (Item) throws -> Void
    ) {
        self.get = get
        self.valueExistsForItem = valueExistsForItem
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
    }
}

extension KeychainClient {
    func getQueryResult(_ item: Item) throws -> QueryResult? {
        try get(item).first
    }
}

// String convenience methods
extension KeychainClient {
    func get(_ item: Item) throws -> String? {
        try get(item)
            .first
            .flatMap(\.stringValue)
    }

    func set(_ value: String, for item: Item) throws {
        try setValueForItem(
            .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessPolicy: nil),
            item
        )
    }
}

// Private key registration convenience methods
extension KeychainClient {
    func set(
        key: Data,
        registration: KeyRegistration,
        accessPolicy: Item.AccessPolicy
    ) throws {
        try setValueForItem(
            .init(
                data: key,
                account: nil, // By setting as nil, the primary key will be the Item.name and nil, thus allowing only one registration to be stored.
                label: registration.userLabel,
                generic: jsonEncoder.encode(registration),
                accessPolicy: accessPolicy
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
        let account: String?
        let generic: Data?

        var stringValue: String? {
            String(data: data, encoding: .utf8)
        }
    }

    struct KeyRegistration: Codable {
        let userId: User.ID
        let userLabel: String
        let registrationId: User.BiometricRegistration.ID
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
