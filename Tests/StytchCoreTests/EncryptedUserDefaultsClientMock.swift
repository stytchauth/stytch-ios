import CryptoKit
import Foundation
@testable import StytchCore

// used for testing the expiration of the IST
public var userDefaultsLastModifiedOffset = 0

class EncryptedUserDefaultsClientMock: EncryptedUserDefaultsClient {
    let lock: NSLock = .init()
    var userDefaultItems: [String: EncryptedUserDefaultsItemResult] = [:]

    func getItem(item: EncryptedUserDefaultsItem) throws -> EncryptedUserDefaultsItemResult? {
        lock.withLock { userDefaultItems[item.name] }
    }

    func itemExists(item: EncryptedUserDefaultsItem) -> Bool {
        lock.withLock { userDefaultItems[item.name] != nil }
    }

    func setValueForItem(value: String?, item: EncryptedUserDefaultsItem) throws {
        lock.withLock {
            let result: EncryptedUserDefaultsItemResult = .init(data: (value ?? "").data(using: .utf8)!)
            userDefaultItems[item.name] = result
            let lastValidatedAtDate = Date().minutesAgo(minutes: userDefaultsLastModifiedOffset)
            userDefaultItems["\(item.name)_last_validated_at_date"] = try? .init(data: lastValidatedAtDate.asJson(encoder: Current.jsonEncoder).data(using: .utf8)!)
        }
    }

    func removeItem(item: EncryptedUserDefaultsItem) throws {
        lock.withLock {
            userDefaultItems[item.name] = nil
            userDefaultItems["\(item.name)_last_validated_at_date"] = nil
        }
    }
}

extension EncryptedUserDefaultsClient {
    func resultsExistForItem(_ item: EncryptedUserDefaultsItem) -> Bool {
        (try? getStringValue(item).map { !$0.isEmpty }) ?? false
    }
}
