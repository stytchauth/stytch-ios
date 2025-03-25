import Foundation
@testable import StytchCore

// used for testing the expiration of the IST
public var keychainDateCreatedOffsetInMinutes = 0

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
                let queryResult: KeychainClient.QueryResult = .init(
                    data: value.data,
                    createdAt: .init().minutesAgo(minutes: keychainDateCreatedOffsetInMinutes),
                    modifiedAt: .init().minutesAgo(minutes: keychainDateCreatedOffsetInMinutes),
                    label: value.label,
                    account: value.account,
                    generic: value.generic
                )
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
        (try? getStringValue(item).map { !$0.isEmpty }) ?? false
    }
}

extension Date {
    func minutesAgo(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -minutes, to: self) ?? self
    }
}
