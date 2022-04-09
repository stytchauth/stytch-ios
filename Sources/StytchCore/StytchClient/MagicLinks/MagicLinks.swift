public extension StytchClient {
    struct MagicLinks {
        public var email: Email { .init(pathContext: "magic_links") }
    }
}

public extension StytchClient {
    static var magicLinks: MagicLinks { .init() }
}
