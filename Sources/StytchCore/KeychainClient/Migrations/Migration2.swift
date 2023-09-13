import Security

extension KeychainClient {
    struct Migration2: KeychainMigration {
        static func run() throws {
            try [
                KeychainClient.Item.sessionJwt,
                .sessionToken,
                .codeVerifierPKCE,
                .privateKeyRegistration
            ]
            .forEach { item in
                let status = SecItemUpdate(
                    [kSecAttrAccount: item.name as CFString, kSecClass: kSecClassGenericPassword] as CFDictionary,
                    [kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock] as CFDictionary
                )
                guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                    throw KeychainError.unhandledError(status: status)
                }
            }
        }
    }
}
