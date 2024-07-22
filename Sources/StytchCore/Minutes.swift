/// A dedicated type which represents the minutes unit of time.
public struct Minutes: Codable, Equatable {
    let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(UInt.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Minutes: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt) {
        rawValue = value
    }
}

public extension Minutes {
    static let defaultSessionDuration: Self = 5

    static func == (lhs: Minutes, rhs: Minutes) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}
