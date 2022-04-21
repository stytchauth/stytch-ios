public extension StytchClient {
    /// The interface type for all magiclink calls.
    struct MagicLinks {
        private let pathContext: Path = .init(rawValue: "magic_links")

        public var email: Email { .init(pathContext: pathContext) }

        // sourcery: AsyncVariants
        /**
         Wraps the [authenticate](https://stytch.com/docs/api/authenticate-magic-link) Magic link API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
         */
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponse>) {
            StytchClient.post(
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
