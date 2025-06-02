enum AttrStringComponent: Equatable {
    indirect case bold(Self)
    case string(String)
}

extension AttrStringComponent: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .string(value)
    }
}
