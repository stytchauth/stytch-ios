extension StytchClient {
    public struct MagicLinks {
        public var email: Email { .init(pathContext: "magic_links") }
    }
}

extension StytchClient {
    public static var magicLinks: MagicLinks { .init() }
}
