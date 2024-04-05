import Security

extension KeychainClient {
    struct Migration3: KeychainMigration {
        static func run() throws {
            try [
                KeychainClient.Item.privateKeyRegistration,
            ]
            .forEach { item in
                var error: Unmanaged<CFError>?
                defer { error?.release() }
                #if os(macOS)
                let flags: SecAccessControlCreateFlags = [.biometryCurrentSet, .or, .watch]
                #else
                let flags: SecAccessControlCreateFlags = [.biometryCurrentSet]
                #endif
                let accessControl = SecAccessControlCreateWithFlags(
                    nil,
                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                    flags,
                    &error
                )

                var status = SecItemUpdate(
                    [kSecAttrService: item.name as CFString, kSecClass: kSecClassGenericPassword] as CFDictionary,
                    [kSecAttrAccessible: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly] as CFDictionary
                )
                guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                    throw KeychainError.unhandledError(status: status)
                }
                status = SecItemUpdate(
                    [kSecAttrService: item.name as CFString, kSecClass: kSecClassGenericPassword] as CFDictionary,
                    [kSecAttrAccessControl: accessControl] as CFDictionary
                )
                guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                    throw KeychainError.unhandledError(status: status)
                }
            }
        }
    }
}
