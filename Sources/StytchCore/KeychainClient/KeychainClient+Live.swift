import Foundation
import Security
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif

extension KeychainClient {
    static let live: Self = {
        #if canImport(LocalAuthentication)
        let updateQueryWithLAContext: (inout [CFString: Any]) -> LAContext = { query in
            let context = LAContext()
            #if !os(tvOS)
            context.localizedReason = NSLocalizedString(
                "keychain_client.la_context_reason",
                value: "Authenticate with biometrics",
                comment: "The user-presented reason for biometric authentication prompts"
            )
            #endif
            // This could potentially cause prompting for secured items, so we'll pass in a reusable authentication context to minimize prompting
            query[kSecUseAuthenticationContext] = context
            return context
        }
        #endif

        return .init { item in
            var result: CFTypeRef?

            var query = item.getQuery

            #if canImport(LocalAuthentication)
            let context = updateQueryWithLAContext(&query)
            #endif

            guard case errSecSuccess = SecItemCopyMatching(query as CFDictionary, &result) else {
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
        } setValueForItem: { value, item in
            let status: OSStatus

            var query = item.baseQuery

            #if canImport(LocalAuthentication)
            let context = updateQueryWithLAContext(&query)
            #endif

            let itemExists = SecItemCopyMatching(
                query.merging([kSecAttrSynchronizable: kSecAttrSynchronizableAny]) as CFDictionary,
                nil
            ) == errSecSuccess

            if itemExists {
                status = SecItemUpdate(
                    query as CFDictionary,
                    item.updateQuerySegment(for: value) as CFDictionary
                )
            } else {
                status = SecItemAdd(item.insertQuery(value: value), nil)
            }
            if status != errSecSuccess {
                throw KeychainError.unhandledError(status: status)
            }
        } removeItem: { item in
            let status = SecItemDelete(item.baseQuery.merging([kSecAttrSynchronizable: kSecAttrSynchronizableAny]) as CFDictionary)

            guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }()
}
