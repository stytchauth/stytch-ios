import CryptoKit
import Foundation
import Security
#if !os(tvOS)
import LocalAuthentication
#endif

let ENCRYPTEDUSERDEFAULTSKEYNAME = "EncryptedUserDefaultsKey"

final class KeychainClientImplementation: KeychainClient {
    static let shared = KeychainClientImplementation()
    private let queue: DispatchQueue
    private let queueKey = DispatchSpecificKey<Void>()
    var encryptionKey: SymmetricKey?
    private var isOnQueue: Bool {
        DispatchQueue.getSpecific(key: queueKey) != nil
    }

    #if !os(tvOS) && !os(watchOS)
    // Shared reusable private context for the keychain client,
    // always configured with interactionNotAllowed = true
    private let contextWithoutUI = LAContext()
    #endif

    private init() {
        queue = DispatchQueue(label: "StytchKeychainClientQueue")
        queue.setSpecific(key: queueKey, value: ())
        loadEncryptionKey()
        #if !os(tvOS) && !os(watchOS)
        contextWithoutUI.interactionNotAllowed = true
        #endif
    }

    func loadEncryptionKey() {
        try? safelyEnqueue {
            encryptionKey = try? getEncryptionKey()
        }
    }

    func safelyEnqueue<T>(_ block: () throws -> T) throws -> T {
        if isOnQueue {
            return try block()
        } else {
            return try queue.sync { try block() }
        }
    }

    private func getEncryptionKey() throws -> SymmetricKey {
        try safelyEnqueue {
            let result = try getFirstQueryResult(KeychainItem.encryptionKey)
            guard let result else {
                // Key doesn't exist so create it
                let data = SymmetricKey(size: .bits256).withUnsafeBytes {
                    Data(Array($0))
                }
                try setValueForItem(value: .init(data: data, account: ENCRYPTEDUSERDEFAULTSKEYNAME, label: nil, generic: nil, accessPolicy: nil), item: .encryptionKey)
                return SymmetricKey(data: data)
            }
            return SymmetricKey(data: result.data)
        }
    }

    // swiftlint:disable:next function_body_length
    func getQueryResults(item: KeychainItem) throws -> [KeychainQueryResult] {
        try safelyEnqueue {
            var result: CFTypeRef?
            var query = item.getQuery
            #if !os(tvOS) && !os(watchOS)
            query[kSecUseAuthenticationContext] = LocalAuthenticationContextManager.laContext
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
            } else if item.kind == .encryptionKey {
                var newQuery = query
                newQuery[kSecAttrAccount] = ENCRYPTEDUSERDEFAULTSKEYNAME
                status = SecItemCopyMatching(newQuery as CFDictionary, &result)
            } else {
                status = SecItemCopyMatching(query as CFDictionary, &result)
            }

            if let status = status, ![errSecSuccess, errSecItemNotFound].contains(status) {
                throw KeychainError.unhandledError(status: status)
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
    }

    func valueExistsForItem(item: KeychainItem) -> Bool {
        let exists = try? safelyEnqueue {
            var result: CFTypeRef?
            var query = item.getQuery
            #if !os(tvOS) && !os(watchOS)
            query[kSecUseAuthenticationContext] = contextWithoutUI
            #endif
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            return [errSecSuccess, errSecInteractionNotAllowed].contains(status)
        }
        return exists == true
    }

    func setValueForItem(value: KeychainItem.Value, item: KeychainItem) throws {
        try safelyEnqueue {
            let status: OSStatus
            var query = item.baseQuery
            #if !os(tvOS) && !os(watchOS)
            query[kSecUseAuthenticationContext] = LocalAuthenticationContextManager.laContext
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
    }

    func removeItem(item: KeychainItem) throws {
        try safelyEnqueue {
            let tryRemovingItem: (CFDictionary) throws -> Void = { query in
                let status = SecItemDelete(query)
                guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                    throw KeychainError.unhandledError(status: status)
                }
            }
            var parameters: [CFString: AnyObject] = [kSecAttrSynchronizable: kSecAttrSynchronizableAny]
            if item.kind == .encryptionKey {
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
}
