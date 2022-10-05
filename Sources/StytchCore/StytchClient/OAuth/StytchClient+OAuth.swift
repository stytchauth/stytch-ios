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
    var amazon: ThirdPartyProvider { .init(provider: .amazon) }

    /// docs
    var apple: Apple { .init(router: router.scopedRouter(OAuthRoute.apple)) }

    /// docs
    var bitbucket: ThirdPartyProvider { .init(provider: .bitbucket) }

    /// docs
    var coinbase: ThirdPartyProvider { .init(provider: .coinbase) }

    /// docs
    var discord: ThirdPartyProvider { .init(provider: .discord) }

    /// docs
    var facebook: ThirdPartyProvider { .init(provider: .facebook) }

    /// docs
    var github: ThirdPartyProvider { .init(provider: .github) }

    /// docs
    var gitlab: ThirdPartyProvider { .init(provider: .gitlab) }

    /// docs
    var google: ThirdPartyProvider { .init(provider: .google) }

    /// docs
    var linkedin: ThirdPartyProvider { .init(provider: .linkedin) }

    /// docs
    var microsoft: ThirdPartyProvider { .init(provider: .microsoft) }

    /// docs
    var slack: ThirdPartyProvider { .init(provider: .slack) }

    /// docs
    var twitch: ThirdPartyProvider { .init(provider: .twitch) }
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
