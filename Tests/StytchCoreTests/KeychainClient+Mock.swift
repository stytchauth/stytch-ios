@testable import StytchCore

extension KeychainClient {
    static func mock() -> Self {
        var keychainItems: [String: [KeychainClient.QueryResult]] = [:]

        return .init { item in
            keychainItems[item.name] ?? []
        } setValueForItem: { value, item in
            let queryResult: KeychainClient.QueryResult = .init(data: value.data, createdAt: .init(), modifiedAt: .init(), label: value.label, account: value.account, generic: nil)
            var results = keychainItems[item.name, default: []]
            if let index = results.firstIndex(where: { $0.label == queryResult.label && $0.account == queryResult.account }) {
                results[index] = queryResult
            } else {
                results.append(queryResult)
            }
            keychainItems[item.name] = results
        } removeItem: { item in
            keychainItems[item.name] = nil
        }
    }

    func resultsExistForItem(_ item: Item) -> Bool {
        (try? get(item).map { !$0.isEmpty }) ?? false
    }
}
