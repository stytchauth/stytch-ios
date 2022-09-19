/// A dedicated type which represents the minutes unit of time.
public struct Minutes: Codable {
    let rawValue: UInt

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
    /// 30
    static let defaultSessionDuration: Self = 30
}
