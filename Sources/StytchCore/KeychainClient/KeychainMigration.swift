protocol KeychainMigration {
    static func run() throws
}

extension KeychainClient {
    // Migrations must only be added to the bottom of this list so they are run in order
    static let migrations: [KeychainMigration.Type] = [
        Migration1.self,
        Migration2.self,
    ]
}
