@testable import StytchCore
import Foundation

extension KeychainClient {
    static func mock() -> Self {
        let lock: NSLock = .init()
        var keychainItems: [String: [KeychainClient.QueryResult]] = [:]

        return .init { item in
            lock.withLock { keychainItems[item.name] ?? [] }
        } valueExistsForItem: { item in
            lock.withLock { keychainItems[item.name].map { !$0.isEmpty } ?? false }
        } setValueForItem: { value, item in
            lock.withLock {
                let queryResult: KeychainClient.QueryResult = .init(data: value.data, createdAt: .init(), modifiedAt: .init(), label: value.label, account: value.account, generic: nil)
                var results = keychainItems[item.name, default: []]
                if let index = results.firstIndex(where: { $0.label == queryResult.label && $0.account == queryResult.account }) {
                    results[index] = queryResult
                } else {
                    results.append(queryResult)
                }
                keychainItems[item.name] = results
            }
        } removeItem: { item in
            lock.withLock { keychainItems[item.name] = nil }
        }
    }

    func resultsExistForItem(_ item: Item) -> Bool {
        (try? get(item).map { !$0.isEmpty }) ?? false
    }
}
