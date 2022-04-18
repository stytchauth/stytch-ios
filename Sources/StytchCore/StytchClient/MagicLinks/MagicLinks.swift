public extension StytchClient {
    struct MagicLinks {
        private let pathContext: Path = .init(rawValue: "magic_links")

        public var email: Email { .init(pathContext: pathContext) }

        // sourcery: AsyncVariants
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponse>) {
            StytchClient.instance.post(
                parameters: parameters,
                path: pathContext.appendingPathComponent("authenticate"),
                completion: completion
            )
        }
    }
}

public extension StytchClient {
    static var magicLinks: MagicLinks { .init() }
}
