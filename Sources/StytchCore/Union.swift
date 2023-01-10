@dynamicMemberLookup
public struct Union<LHS, RHS> {
    let lhs: LHS
    let rhs: RHS

    init(lhs: LHS, rhs: RHS) {
        self.lhs = lhs
        self.rhs = rhs
    }

    public subscript<T>(dynamicMember member: KeyPath<LHS, T>) -> T {
        lhs[keyPath: member]
    }

    public subscript<T>(dynamicMember member: KeyPath<RHS, T>) -> T {
        rhs[keyPath: member]
    }
}

extension Union: Codable where LHS: Codable, RHS: Codable {
    public init(from decoder: Decoder) throws {
        lhs = try .init(from: decoder)
        rhs = try .init(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try lhs.encode(to: encoder)
        try rhs.encode(to: encoder)
    }
}
