import Foundation
import Security

extension KeychainClient {
    static let live: Self = .init(
        getItem: { item in
            var result: CFTypeRef?

            guard case errSecSuccess = SecItemCopyMatching(item.getQuery, &result) else {
                return nil
            }
            guard let data = result as? Data else {
                throw KeychainError.resultNotData
            }

            return String(data: data, encoding: .utf8)
        },
        setValueForItem: { client, value, item in
            let status: OSStatus

            if client.resultExists(for: item) {
                status = SecItemUpdate(
                    item.baseQuery as CFDictionary,
                    item.querySegmentForUpdate(for: value) as CFDictionary
                )
            } else {
                status = SecItemAdd(item.insertQuery(value: value), nil)
            }
            if status != errSecSuccess {
                throw KeychainError.unhandledError(status: status)
            }
        },
        removeItem: { client, item in
            guard client.resultExists(for: item) else {
                return
            }

            let status = SecItemDelete(item.baseQuery as CFDictionary)

            if status != errSecSuccess {
                throw KeychainError.unhandledError(status: status)
            }
        },
        resultExists: { item in
            SecItemCopyMatching(item.baseQuery as CFDictionary, nil) == errSecSuccess
        }
    )
}
