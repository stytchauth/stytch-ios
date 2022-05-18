public extension StytchClient {
    /// Magic links can be sent via email and allow for a quick and seamless login experience.
    struct MagicLinks {
        let pathContext: Endpoint.Path = "magic_links"

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps the magic link [authenticate](https://stytch.com/docs/api/authenticate-magic-link) API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponse>) {
            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: parameters,
                completion: completion
            )
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with magic-links products.
    static var magicLinks: MagicLinks { .init() }
}
