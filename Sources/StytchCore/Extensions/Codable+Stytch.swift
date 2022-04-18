// swiftlint:disable:this file_name

import Foundation

extension KeyedDecodingContainer {
    func decode<T: Decodable>(key: Key) throws -> T {
        try decode(T.self, forKey: key)
    }
}
