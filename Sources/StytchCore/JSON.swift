import Foundation

/// A simple type representing valid JSON values which includes several convenience accessors.
public enum JSON: Hashable, Equatable, Sendable {
    case array([JSON])
    case object([String: JSON?])
    case string(String)
    case number(Double)
    case boolean(Bool)

    public var arrayValue: [JSON]? {
        guard case let .array(value) = self else { return nil }
        return value
    }

    public var objectValue: [String: JSON?]? {
        guard case let .object(value) = self else { return nil }
        return value
    }

    public var stringValue: String? {
        guard case let .string(value) = self else { return nil }
        return value
    }

    public var boolValue: Bool? {
        guard case let .boolean(value) = self else { return nil }
        return value
    }

    public var numberValue: Double? {
        guard case let .number(value) = self else { return nil }
        return value
    }

    init() {
        self = .object([:])
    }

    public subscript(key: String) -> JSON? {
        guard case let .object(dict) = self else {
            return nil
        }

        if let value = dict[key] {
            return value
        } else {
            return nil
        }
    }

    public subscript(_ index: Int) -> JSON? {
        guard case let .array(arr) = self else { return nil }
        return arr[index]
    }
}

public extension Optional where Wrapped == JSON {
    subscript(_ index: Int) -> JSON? {
        self?[index]
    }

    subscript(_ key: String) -> JSON? {
        self?[key]
    }

    subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T? {
        self?[keyPath: member]
    }
}

extension JSON: Codable {
    public init(from decoder: Decoder) throws {
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
                        self = .object(try container.decode([String: JSON?].self))
                    }
                }
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(values):
            struct RawKey: CodingKey {
                let intValue: Int?
                let stringValue: String

                init(stringValue: String) {
                    self.stringValue = stringValue
                    intValue = nil
                }

                init?(intValue: Int) {
                    self.intValue = intValue
                    stringValue = ""
                }
            }
            var container = encoder.container(keyedBy: RawKey.self)
            for (key, value) in values {
                try container.encode(value, forKey: RawKey(stringValue: key))
            }
        case let .array(values):
            var container = encoder.unkeyedContainer()
            for value in values {
                try container.encode(value)
            }
        case let .boolean(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case let .number(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case let .string(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        self = .object(elements.reduce(into: [:]) { $0[$1.0] = $1.1 })
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}
