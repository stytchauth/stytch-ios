enum AttrStringComponent: Equatable {
    indirect case bold(AttrStringComponent)
    case string(String)
}

extension AttrStringComponent: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .string(value)
    }
}
