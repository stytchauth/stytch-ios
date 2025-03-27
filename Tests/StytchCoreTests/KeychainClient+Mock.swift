import Foundation
@testable import StytchCore

// used for testing the expiration of the IST
public var keychainDateCreatedOffsetInMinutes = 0

class KeychainClientMock: KeychainClient {
    let lock: NSLock = .init()
    var keychainItems: [String: [KeychainQueryResult]] = [:]

    func getQueryResults(item: StytchCore.KeychainItem) throws -> [StytchCore.KeychainQueryResult] {
        lock.withLock { keychainItems[item.name] ?? [] }
    }

    func valueExistsForItem(item: StytchCore.KeychainItem) -> Bool {
        lock.withLock { keychainItems[item.name].map { !$0.isEmpty } ?? false }
    }

    func setValueForItem(value: StytchCore.KeychainItem.Value, item: StytchCore.KeychainItem) throws {
        lock.withLock {
            let queryResult: KeychainQueryResult = .init(
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
    }

    func removeItem(item: StytchCore.KeychainItem) throws {
        lock.withLock { keychainItems[item.name] = nil }
    }
}

extension KeychainClient {
    func resultsExistForItem(_ item: KeychainItem) -> Bool {
        (try? getStringValue(item).map { !$0.isEmpty }) ?? false
    }
}

extension Date {
    func minutesAgo(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -minutes, to: self) ?? self
    }
}
