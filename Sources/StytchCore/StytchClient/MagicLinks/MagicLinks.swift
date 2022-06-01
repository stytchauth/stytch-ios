public extension StytchClient {
    /// Magic links can be sent via email and allow for a quick and seamless login experience.
    struct MagicLinks {
        let pathContext: Endpoint.Path = "magic_links"

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps the magic link [authenticate](https://stytch.com/docs/api/authenticate-magic-link) API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponse>) {
            guard let codeVerifier = try? Current.keychainClient.get(.stytchPKCECodeVerifier) else {
                completion(.failure(StytchError.pckeNotAvailable))
                return
            }
            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: StytchClient.tokenizedParameters(
                    CodeVerifierParameters(codeVerifier: codeVerifier, wrapped: parameters)
                ),
                completion: StytchClient.pckeAuthenticateCompletion(completion)
            )
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with magic-links products.
    static var magicLinks: MagicLinks { .init() }
}

private extension StytchClient.MagicLinks {
    struct CodeVerifierParameters<T: Encodable>: Encodable {
        private enum CodingKeys: String, CodingKey { case codeVerifier }

        let codeVerifier: String
        let wrapped: T

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try wrapped.encode(to: encoder)

            try container.encode(codeVerifier, forKey: .codeVerifier)
        }
    }
}

extension StytchClient {
    static func tokenizedParameters<T: Encodable>(_ parameters: T) -> some Encodable {
        TokenizedParameters(
            parameters: parameters,
            token: sessions.sessionToken ?? sessions.sessionJwt
        )
    }
}
