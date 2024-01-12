// swiftlint:disable:this file_name

import Foundation

extension KeyedDecodingContainer {
    func decode<T: Decodable>(key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }

    func optionalDecode<T: Decodable>(key: Key) throws -> T? {
        try decodeIfPresent(T.self, forKey: key)
    }
}

extension Encodable {
    func base64EncodedString(encoder: JSONEncoder) throws -> String {
        (try encoder.encode(self)).base64EncodedString()
    }

    func asJson(encoder: JSONEncoder) throws -> String {
        guard let jsonString = String(data: try encoder.encode(self), encoding: .utf8) else {
            throw StytchSDKError.jsonDataNotConvertibleToString
        }
        return jsonString
    }
}
