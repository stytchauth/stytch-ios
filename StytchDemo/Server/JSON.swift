import Foundation

enum JSON {
    struct Error: Swift.Error {}

    case array([JSON])
    case object([String: JSON])
    case string(String)
    case number(Double)
    case boolean(Bool)

    subscript(key: String) -> JSON? {
        guard case let .object(dict) = self else { return nil }
        return dict[key]
    }

    subscript(_ index: Int) -> JSON? {
        guard case let .array(arr) = self else { return nil }
        return arr[index]
    }

    var stringValue: String? {
        if case let .string(value) = self {
            return value
        }
        return nil
    }

    var boolValue: Bool? {
        if case let .boolean(value) = self {
            return value
        }
        return nil
    }

    var numberValue: Double? {
        if case let .number(value) = self {
            return value
        }
        return nil
    }
}

extension Optional where Wrapped == JSON {
    subscript(_ index: Int) -> JSON? {
        self?[index]
    }

    subscript(_ key: String) -> JSON? {
        self?[key]
    }

    var stringValue: String? {
        self?.stringValue
    }

    var boolValue: Bool? {
        self?.boolValue
    }

    var numberValue: Double? {
        self?.numberValue
    }
}

extension JSON: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(elements.reduce(into: [:]) { $0[$1.0] = $1.1 })
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension JSON: Decodable {
    init(from decoder: Decoder) throws {
        do {
            var container = try decoder.unkeyedContainer()
            var json: [JSON] = []
            while !container.isAtEnd {
                json.append(try container.decode(JSON.self))
            }
            self = .array(json)
        } catch {
            let container = try decoder.singleValueContainer()
            do {
                self = .boolean(try container.decode(Bool.self))
            } catch {
                do {
                    self = .number(try container.decode(Double.self))
                } catch {
                    do {
                        self = .string(try container.decode(String.self))
                    } catch {
                        self = .object(try container.decode([String: JSON].self))
                    }
                }
            }
        }
    }
}
