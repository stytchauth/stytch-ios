import Foundation

struct KeychainClient {
    let getQueryResults: (Item) throws -> [QueryResult]
    let valueExistsForItem: (Item) -> Bool
    let setValueForItem: (Item.Value, Item) throws -> Void
    let removeItem: (Item) throws -> Void

    @Dependency(\.jsonEncoder) var jsonEncoder
    @Dependency(\.jsonDecoder) var jsonDecoder

    init(
        getQueryResults: @escaping (Item) throws -> [QueryResult],
        valueExistsForItem: @escaping (Item) -> Bool,
        setValueForItem: @escaping (Item.Value, Item) throws -> Void,
        removeItem: @escaping (Item) throws -> Void
    ) {
        self.getQueryResults = getQueryResults
        self.valueExistsForItem = valueExistsForItem
        self.setValueForItem = setValueForItem
        self.removeItem = removeItem
    }
}

extension KeychainClient {
    func getFirstQueryResult(_ item: Item) throws -> QueryResult? {
        try getQueryResults(item).first
    }
}

// String convenience methods
extension KeychainClient {
    func getStringValue(_ item: Item) throws -> String? {
        try getQueryResults(item)
            .first
            .flatMap(\.stringValue)
    }

    func setStringValue(_ value: String, for item: Item) throws {
        try setValueForItem(
            .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessPolicy: nil),
            item
        )
    }
}

// Private key registration convenience methods
extension KeychainClient {
    func setPrivateKeyRegistration(
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
