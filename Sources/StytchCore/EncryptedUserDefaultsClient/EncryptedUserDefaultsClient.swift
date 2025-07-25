import Foundation

protocol EncryptedUserDefaultsClient: AnyObject {
    func getItem(item: EncryptedUserDefaultsItem) throws -> EncryptedUserDefaultsItemResult?
    func itemExists(item: EncryptedUserDefaultsItem) -> Bool
    func setValueForItem(value: String?, item: EncryptedUserDefaultsItem) throws
    func removeItem(item: EncryptedUserDefaultsItem) throws
}

extension EncryptedUserDefaultsClient {
    func getObject<T: Decodable>(_: T.Type, for item: EncryptedUserDefaultsItem) throws -> T? {
        guard let result = try getItem(item: item), result.stringValue != "null" else {
            return nil
        }
        do {
            return try Current.jsonDecoder.decode(T.self, from: result.data)
        } catch {
            Task {
                let details: [String: String] = [
                    "type": item.name,
                    "json": result.stringValue ?? "No String Value",
                ]
                try? await EventsClient.logEvent(parameters: .init(eventName: "json_decoding_error", details: details))
            }
            throw EncryptedUserDefaultsError.dataCouldNotBeMarshalled
        }
    }

    func getStringValue(_ item: EncryptedUserDefaultsItem) throws -> String? {
        do {
            return try getItem(item: item)?.stringValue
        } catch {
            return nil
        }
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

public enum EncryptedUserDefaultsError: Error {
    case encryptionKeyNotAvailable
    case noDataFound
    case dataCouldNotBeDecrypted
    case decryptedDataWasNil
    case decryptedDataCouldNotBeStringified
    case dataCouldNotBeMarshalled
    case metadataIsMissing
    case dataIsExpired
}
