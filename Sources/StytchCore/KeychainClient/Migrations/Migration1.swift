import Security

extension KeychainClient {
    struct Migration1: KeychainMigration {
        static func run() throws {
            try [
                KeychainClient.Item.sessionJwt,
                .sessionToken,
            ]
            .forEach { item in
                let status = SecItemUpdate(
                    [kSecAttrAccount: item.name as CFString, kSecClass: kSecClassGenericPassword] as CFDictionary,
                    [kSecAttrService: item.name] as CFDictionary
                )
                guard [errSecSuccess, errSecItemNotFound].contains(status) else {
                    throw KeychainError.unhandledError(status: status)
                }
            }
        }
    }
}
