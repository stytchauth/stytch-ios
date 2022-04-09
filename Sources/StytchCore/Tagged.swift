// TODO: - provide pointfreeco attribution
public struct Tagged<Tag, RawValue> {
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension Tagged: Encodable where RawValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
