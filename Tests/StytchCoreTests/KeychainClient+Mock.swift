@testable import StytchCore

extension KeychainClient {
    static func mock() -> Self {
        var keychainItems: [String: [KeychainClient.QueryResult]] = [:]

        return .init { item in
            keychainItems[item.name] ?? []
        } setValueForItem: { value, item in
            keychainItems[item.name] = [
                .init(data: value.data, createdAt: .init(), modifiedAt: .init(), label: value.label, account: value.account ?? "not_set", generic: nil),
            ]
        } removeItem: { item in
            keychainItems[item.name] = nil
        }
    }

    func resultsExistForItem(_ item: Item) -> Bool {
        (try? get(item).map { !$0.isEmpty }) ?? false
    }
}
