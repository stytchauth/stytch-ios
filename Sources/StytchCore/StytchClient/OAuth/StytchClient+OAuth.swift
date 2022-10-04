import Foundation

public extension StytchClient {
    /// docs
    struct OAuth {
        let router: NetworkingRouter<OAuthRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// docs
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponseType {
            guard let codeVerifier: String = try Current.keychainClient.get(.oauthPKCECodeVerifier) else {
                throw StytchError.pckeNotAvailable
            }

            return try await router.post(
                to: .authenticate,
                parameters: CodeVerifierParameters(codeVerifier: codeVerifier, wrapped: parameters)
            ) as AuthenticateResponse
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with OAuth products.
    static var oauth: OAuth { .init(router: router.scopedRouter(BaseRoute.oauth)) }
}

public extension StytchClient.OAuth {
    /// docs
    var amazon: GenericProvider { .init(provider: .amazon) }

    /// docs
    var apple: Apple { .init(router: router.scopedRouter(OAuthRoute.apple)) }

    /// docs
    var bitbucket: GenericProvider { .init(provider: .bitbucket) }

    /// docs
    var coinbase: GenericProvider { .init(provider: .coinbase) }

    /// docs
    var discord: GenericProvider { .init(provider: .discord) }

    /// docs
    var facebook: GenericProvider { .init(provider: .facebook) }

    /// docs
    var github: GenericProvider { .init(provider: .github) }

    /// docs
    var gitlab: GenericProvider { .init(provider: .gitlab) }

    /// docs
    var google: GenericProvider { .init(provider: .google) }

    /// docs
    var linkedin: GenericProvider { .init(provider: .linkedin) }

    /// docs
    var microsoft: GenericProvider { .init(provider: .microsoft) }

    /// docs
    var slack: GenericProvider { .init(provider: .slack) }

    /// docs
    var twitch: GenericProvider { .init(provider: .twitch) }
}

public extension StytchClient.OAuth {
    /// docs
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case token, sessionDuration = "session_duration_minutes" }

        let token: String
        let sessionDuration: Minutes

        /// docs
        public init(
            token: String,
            sessionDuration: Minutes = .defaultSessionDuration
        ) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }
}
