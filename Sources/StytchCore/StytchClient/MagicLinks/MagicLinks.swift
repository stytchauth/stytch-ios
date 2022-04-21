public extension StytchClient {
    /// The interface type for magic links.
    struct MagicLinks {
        let pathContext: Endpoint.Path = .init(rawValue: "magic_links")

        // sourcery: AsyncVariants
        /**
         Wraps the [authenticate](https://stytch.com/docs/api/authenticate-magic-link) Magic link API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
         */
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
    /// The interface implementation for magic links.
    static var magicLinks: MagicLinks { .init() }
}
