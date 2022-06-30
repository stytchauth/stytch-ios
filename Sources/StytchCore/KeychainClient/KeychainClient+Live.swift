import Foundation
import Security

extension KeychainClient {
    static let live: Self = .init { item in
        var result: CFTypeRef?

        guard case errSecSuccess = SecItemCopyMatching(item.getQuery, &result) else {
            return []
        }
        guard let results = result as? [[CFString: Any]] else {
            throw KeychainError.resultNotArray
        }

        return try results.compactMap { dict in
            guard let data = dict[kSecValueData] as? Data else { throw KeychainError.resultNotData }
            guard let account = dict[kSecAttrAccount] as? String else { throw KeychainError.resultMissingAccount }
            guard
                let createdAt = dict[kSecAttrCreationDate] as? Date,
                let modifiedAt = dict[kSecAttrModificationDate] as? Date
            else { throw KeychainError.resultMissingDates }

            return QueryResult(
                data: data,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                label: dict[kSecAttrLabel] as? String,
                account: account,
                generic: dict[kSecAttrGeneric] as? Data
            )
        }
    } setValueForItem: { client, itemData, item in
        let status: OSStatus

        if client.resultsExistForItem(item) {
            status = SecItemUpdate(
                item.baseQuery as CFDictionary,
                item.updateQuerySegment(for: itemData) as CFDictionary
            )
        } else {
            status = SecItemAdd(item.insertQuery(itemData: itemData), nil)
        }
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    } removeItem: { item in
        let status = SecItemDelete(item.baseQuery as CFDictionary)

        guard [errSecSuccess, errSecItemNotFound].contains(status) else {
            throw KeychainError.unhandledError(status: status)
        }
    } resultsExistForItem: { item in
        SecItemCopyMatching(item.baseQuery as CFDictionary, nil) == errSecSuccess
    }
}
