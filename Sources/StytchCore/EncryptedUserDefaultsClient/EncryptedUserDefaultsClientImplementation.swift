import CryptoKit
import Foundation

final class EncryptedUserDefaultsClientImplementation: EncryptedUserDefaultsClient {
    static let shared = EncryptedUserDefaultsClientImplementation()
    @Dependency(\.keychainClient) private var keychainClient
    private let queue: DispatchQueue
    private let queueKey = DispatchSpecificKey<Void>()

    private var isOnQueue: Bool {
        DispatchQueue.getSpecific(key: queueKey) != nil
    }

    internal let defaults: UserDefaults = .init(suiteName: "StytchEncryptedUserDefaults") ?? .standard

    private init() {
        queue = DispatchQueue(label: "StytchEncryptedUserDefaultsClientQueue")
        queue.setSpecific(key: queueKey, value: ())
    }

    private func safelyEnqueue<T>(_ block: () throws -> T) throws -> T {
        if isOnQueue {
            return try block()
        } else {
            return try queue.sync { try block() }
        }
    }

    func getItem(item: EncryptedUserDefaultsItem) throws -> EncryptedUserDefaultsItemResult? {
        try safelyEnqueue {
            let userDefaultsData = defaults.data(forKey: item.name)
            guard let decrypted = decryptData(encryptedData: userDefaultsData) else {
                return nil
            }
            guard let data = decrypted.data(using: .utf8) else {
                return nil
            }
            return .init(data: data)
        }
    }

    func itemExists(item: EncryptedUserDefaultsItem) -> Bool {
        let result = try? safelyEnqueue {
            let encryptedData = defaults.data(forKey: item.name)
            return encryptedData != nil
        }
        return result ?? false
    }

    func setValueForItem(value: String?, item: EncryptedUserDefaultsItem) throws {
        try safelyEnqueue {
            guard let valueString = value else {
                return removeItem(item: item)
            }
            let encryptedText = try encryptString(plainText: valueString)
            defaults.set(encryptedText, forKey: item.name)
            let encryptedDate = try encryptString(plainText: Date().asJson(encoder: Current.jsonEncoder))
            defaults.set(encryptedDate, forKey: EncryptedUserDefaultsItem.lastValidatedAtDate(item.name).name)
        }
    }

    func removeItem(item: EncryptedUserDefaultsItem) {
        try? safelyEnqueue {
            defaults.removeObject(forKey: item.name)
            defaults.removeObject(forKey: EncryptedUserDefaultsItem.lastValidatedAtDate(item.name).name)
        }
    }

    private func encryptString(plainText: String) throws -> Data? {
        try safelyEnqueue {
            guard let encryptionKey = keychainClient.encryptionKey else { return nil }
            let sealedBox = try AES.GCM.seal(
                Data(plainText.utf8),
                using: encryptionKey
            )
            return sealedBox.combined
        }
    }

    private func decryptData(encryptedData: Data?) -> String? {
        try? safelyEnqueue {
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
}
