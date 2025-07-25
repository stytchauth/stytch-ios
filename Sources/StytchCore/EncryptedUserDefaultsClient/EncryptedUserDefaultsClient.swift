import Foundation

protocol EncryptedUserDefaultsClient: AnyObject {
    func getItem(item: EncryptedUserDefaultsItem) throws -> EncryptedUserDefaultsItemResult?
    func itemExists(item: EncryptedUserDefaultsItem) -> Bool
    func setValueForItem(value: String?, item: EncryptedUserDefaultsItem) throws
    func removeItem(item: EncryptedUserDefaultsItem) throws
}

extension EncryptedUserDefaultsClient {
    func getObject<T: Decodable>(_: T.Type, for item: EncryptedUserDefaultsItem) throws -> T? {
        guard let result = try getItem(item: item) else {
            return nil
        }
        let data = try Current.jsonDecoder.decode(T.self, from: result.data)
        return data
    }

    func getStringValue(_ item: EncryptedUserDefaultsItem) throws -> String? {
        try getItem(item: item)?.stringValue
    }

    func setObjectValue<T: Encodable>(_ data: T, for item: EncryptedUserDefaultsItem) throws {
        let data = try Current.jsonEncoder.encode(data.self)
        try setValueForItem(value: String(data: data, encoding: .utf8), item: item)
    }

    func setStringValue(_ value: String, for item: EncryptedUserDefaultsItem) throws {
        try setValueForItem(value: value, item: item)
    }
}

struct EncryptedUserDefaultsItemResult {
    let data: Data

    var stringValue: String? {
        String(data: data, encoding: .utf8)
    }
}

enum EncryptedUserDefaultsError: Error {
    case encryptionKeyNotSet
}
