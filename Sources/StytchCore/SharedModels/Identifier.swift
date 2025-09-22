/// A generic type which enables type-safety for string-based identifiers.
public struct Identifier<T, RawValue: Sendable>: Sendable {
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension Identifier: Equatable where RawValue: Equatable {}

extension Identifier: ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral where RawValue == String {
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension Identifier: Codable where RawValue == String {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(RawValue.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
