import Security

struct KeychainMigration2: KeychainMigration {
    static func run() throws {
        try [
            KeychainItem.sessionJwt,
            .sessionToken,
            .codeVerifierPKCE,
            .privateKeyRegistration,
        ]
        .forEach { item in
            let status = SecItemUpdate(
                [kSecAttrService: item.name as CFString, kSecClass: kSecClassGenericPassword] as CFDictionary,
                [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock] as CFDictionary
            )
            guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
}
