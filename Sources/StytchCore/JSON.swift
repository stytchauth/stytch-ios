import Foundation

enum JSON: Equatable {
    case array([JSON])
    case bool(Bool)
    case double(Double)
    case integer(Int)
    case null
    case object([String: JSON])
    case string(String)
}

extension JSON: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .array(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .integer(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        case let .object(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        }
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(elements.reduce(into: [:]) { $0[$1.0] = $1.1 })
    }
}

extension JSON: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByNilLiteral {
    init(nilLiteral _: ()) {
        self = .null
    }
}

extension JSON: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: JSON...) {
        self = .array(elements.map { $0 })
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    init(integerLiteral value: IntegerLiteralType) {
        self = .integer(value)
    }
}

//
// extension JSON: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        switch self {
//        case let .string(value):
//            return "\"\(value)\""
//        case let .integer(value):
//            return "\(value)"
//        case let .double(value):
//            return "\(value)"
//        case let .object(value):
//            let sorted = value
//                .sorted(by: { $0.key < $1.key })
//
//            var string = sorted
//                .dropLast()
//                .reduce(into: "[\n") { partial, next in
//                    partial.append("  \"\(next.key)\": \(next.value),\n")
//                }
//            sorted.last.map { string.append("  \"\($0.key)\": \($0.value)\n") }
//            string.append("]")
//            return string
//        case let .array(value):
//            return "\(value)"
//        case let .bool(value):
//            return "\(value)"
//        case .null:
//            return "null"
//        }
//    }
// }
//
// extension JSON: Decodable {
//    init(from decoder: Decoder) throws {
//        do {
//            let container = try decoder.singleValueContainer()
//
//            if container.decodeNil() {
//                self = .null
//                return
//            }
//
//            do {
//                self = .string(try container.decode())
//                return
//            } catch {
//                do {
//                    self = .integer(try container.decode())
//                    return
//                } catch {
//                    do {
//                        self = .double(try container.decode())
//                        return
//                    } catch {
//                        do {
//                            self = .bool(try container.decode())
//                            return
//                        } catch {
//                            do {
//                                self = .object(try container.decode())
//                                return
//                            } catch {
//                                do {
//                                    self = .array(try container.decode())
//                                    return
//                                } catch {
//                                    throw error
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } catch {
//            do {
//                var container = try decoder.unkeyedContainer()
//                var array: [JSON] = []
//                while !container.isAtEnd {
//                    if try container.decodeNil() {
//                        array.append(.null)
//                        break
//                    }
//
//                    do {
//                        array.append(.string(try container.decode()))
//                    } catch {
//                        do {
//                            array.append(.integer(try container.decode()))
//                        } catch {
//                            do {
//                                array.append(.double(try container.decode()))
//                            } catch {
//                                do {
//                                    array.append(.bool(try container.decode()))
//                                } catch {
//                                    do {
//                                        array.append(.object(try container.decode()))
//                                    } catch {
//                                        do {
//                                            array.append(.array(try container.decode()))
//                                        } catch {
//                                            throw error
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                self = .array(array)
//            } catch {
//                print(error)
//                self = .null
//            }
//        }
//    }
// }
//
// extension SingleValueDecodingContainer {
//    func decode<T: Decodable>(type: T.Type = T.self) throws -> T {
//        try decode(type)
//    }
// }
//
// extension UnkeyedDecodingContainer {
//    mutating func decode<T: Decodable>(type: T.Type = T.self) throws -> T {
//        try decode(type)
//    }
// }
//
//
////let encoder = JSONEncoder()
////encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
////let dict: JSON = [
////    "blah": ["blah": "blah"],
////    "blaz": 1.5,
////    "bl": 1,
////    "bll": false,
////    "asdf": nil,
////    "blz": "asdf",
////    "wer": [123, 345, nil, nil]
////]
////let data = try! encoder.encode(dict)
////print(String(data: data, encoding: .utf8)!)
////print(data.base64EncodedString())
////let decoder = JSONDecoder()
////print(try! decoder.decode(JSON.self, from: data))
