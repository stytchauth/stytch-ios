import Foundation

struct DataContainer<T: Decodable>: Decodable {
    var data: T
}

extension DataContainer: Encodable where T: Encodable {}
