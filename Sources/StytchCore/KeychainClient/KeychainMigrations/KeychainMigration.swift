import Foundation

protocol KeychainMigration {
    static func run() throws
}

extension KeychainClient {
    // Migrations must only be added to the bottom of this list so they are run in order
    func migrations() -> [KeychainMigration.Type] {
        [
            KeychainMigration1.self,
            KeychainMigration2.self,
            KeychainMigration3.self,
            KeychainMigration4.self,
        ]
    }
}
