import CryptoKit
import Foundation

class EncryptedUserDefaultsClientImplementation: EncryptedUserDefaultsClient {
    private let keychainClient: KeychainClient

    internal let defaults: UserDefaults = .init(suiteName: "StytchEncryptedUserDefaults") ?? .standard

    init(keychainClient: KeychainClient) {
        self.keychainClient = keychainClient
    }

    func getItem(item: EncryptedUserDefaultsItem) throws -> EncryptedUserDefaultsItemResult? {
        let userDefaultsData = defaults.data(forKey: item.name)
        guard let decrypted = decryptData(encryptedData: userDefaultsData) else {
            return nil
        }
        guard let data = decrypted.data(using: .utf8) else {
            return nil
        }
        return .init(data: data)
    }

    func itemExists(item: EncryptedUserDefaultsItem) -> Bool {
        let encryptedData = defaults.data(forKey: item.name)
        return encryptedData != nil
    }

    func setValueForItem(value: String?, item: EncryptedUserDefaultsItem) throws {
        guard let valueString = value else {
            return removeItem(item: item)
        }
        let encryptedText = try encryptString(plainText: valueString)
        defaults.set(encryptedText, forKey: item.name)
        let encryptedDate = try encryptString(plainText: Date().asJson(encoder: Current.jsonEncoder))
        defaults.set(encryptedDate, forKey: EncryptedUserDefaultsItem.lastValidatedAtDate(item.name).name)
    }

    func removeItem(item: EncryptedUserDefaultsItem) {
        defaults.removeObject(forKey: item.name)
        defaults.removeObject(forKey: EncryptedUserDefaultsItem.lastValidatedAtDate(item.name).name)
    }

    private func encryptString(plainText: String) throws -> Data? {
        guard let encryptionKey = keychainClient.encryptionKey else { return nil }
        let sealedBox = try AES.GCM.seal(
            Data(plainText.utf8),
            using: encryptionKey
        )
        return sealedBox.combined
    }

    private func decryptData(encryptedData: Data?) -> String? {
        guard let encryptionKey = keychainClient.encryptionKey, let encryptedData else { return nil }
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
