import Foundation
import Security
#if !os(tvOS)
import LocalAuthentication
#endif

// swiftlint:disable function_body_length

class KeychainClientImplementation: KeychainClient {
    func getQueryResults(item: KeychainItem) throws -> [KeychainQueryResult] {
        var result: CFTypeRef?

        var query = item.getQuery

        #if !os(tvOS)
        updateQueryWithLAContext(&query)
        #endif
        var status: OSStatus?
        if item.kind == .privateKey {
            // recursively check each potential type of access control flag
            var potentialFlags: [SecAccessControlCreateFlags] = [
                [.userPresence],
                [.biometryCurrentSet],
            ]

            #if os(macOS)
            potentialFlags.append([.biometryCurrentSet, .or, .watch])
            #endif

            for flags in potentialFlags {
                var error: Unmanaged<CFError>?

                defer {
                    error?.release()
                }

                let accessControl = SecAccessControlCreateWithFlags(
                    nil,
                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                    flags,
                    &error
                )

                var newQuery = query
                newQuery[kSecAttrAccessControl] = accessControl
                status = SecItemCopyMatching(newQuery as CFDictionary, &result)

                if status == errSecSuccess {
                    break
                }
            }
        } else {
            status = SecItemCopyMatching(query as CFDictionary, &result)
        }

        guard case errSecSuccess = status else {
            return []
        }

        guard let results = result as? [[CFString: Any]] else {
            throw KeychainError.resultNotArray
        }

        return try results.compactMap { dict in
            guard let data = dict[kSecValueData] as? Data else {
                throw KeychainError.resultNotData
            }

            guard let account = dict[kSecAttrAccount] as? String else {
                throw KeychainError.resultMissingAccount
            }

            guard let createdAt = dict[kSecAttrCreationDate] as? Date, let modifiedAt = dict[kSecAttrModificationDate] as? Date else {
                throw KeychainError.resultMissingDates
            }

            let label = dict[kSecAttrLabel] as? String
            let generic = dict[kSecAttrGeneric] as? Data

            return KeychainQueryResult(
                data: data,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                label: label,
                account: account,
                generic: generic
            )
        }
    }

    func valueExistsForItem(item: KeychainItem) -> Bool {
        var result: CFTypeRef?
        var query = item.getQuery

        #if !os(tvOS)
        let context = updateQueryWithLAContext(&query)
        context.interactionNotAllowed = true
        #endif

        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return [errSecSuccess, errSecInteractionNotAllowed].contains(status)
    }

    func setValueForItem(value: KeychainItem.Value, item: KeychainItem) throws {
        let status: OSStatus

        var query = item.baseQuery

        #if !os(tvOS)
        _ = updateQueryWithLAContext(&query)
        #endif

        if valueExistsForItem(item: item) {
            let queryDict = query as CFDictionary
            let attributesToUpdate = item.updateQuerySegment(for: value) as CFDictionary
            status = SecItemUpdate(queryDict, attributesToUpdate)
        } else {
            status = SecItemAdd(item.insertQuery(value: value), nil)
        }

        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func removeItem(item: KeychainItem) throws {
        let tryRemovingItem: (CFDictionary) throws -> Void = { query in
            let status = SecItemDelete(query)
            guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                throw KeychainError.unhandledError(status: status)
            }
        }

        var parameters: [CFString: AnyObject] = [kSecAttrSynchronizable: kSecAttrSynchronizableAny]
        if item.kind == .token {
            parameters[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
            try tryRemovingItem(item.baseQuery.merging(parameters))
        } else {
            // recursively check each potential type of access control flag
            var potentialFlags: [SecAccessControlCreateFlags] = [
                [.userPresence],
                [.biometryCurrentSet],
            ]

            #if os(macOS)
            potentialFlags.append([.biometryCurrentSet, .or, .watch])
            #endif

            try potentialFlags.forEach { flags in
                var newParameters = parameters
                var error: Unmanaged<CFError>?

                defer {
                    error?.release()
                }

                let accessControl = SecAccessControlCreateWithFlags(
                    nil,
                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                    flags,
                    &error
                )

                newParameters[kSecAttrAccessControl] = accessControl
                try tryRemovingItem(item.baseQuery.merging(newParameters))
            }
        }
    }
}

extension KeychainClientImplementation {
    #if !os(tvOS)
    @discardableResult
    func updateQueryWithLAContext(_ query: inout [CFString: Any]) -> LAContext {
        let context = LAContext()

        #if !os(watchOS)
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
}
