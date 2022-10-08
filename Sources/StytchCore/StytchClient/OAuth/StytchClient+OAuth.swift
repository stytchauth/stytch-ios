import Foundation

public extension StytchClient {
    /// OAuth allows you to leverage outside identity providers, for which your users may already have an account, to verify their identity. This is a low-friction method your users will be familiar with.
    struct OAuth {
        let router: NetworkingRouter<OAuthRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// After an identity provider confirms the identiy of a user, this method authenticates the included token and returns a new session object.
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
    /// The interface for authenticating a user with Apple.
    var apple: Apple { .init(router: router.scopedRouter(OAuthRoute.apple)) }
}

#if !os(watchOS)
public extension StytchClient.OAuth {
    /// The interface for authenticating a user with Amazon.
    var amazon: ThirdParty { .init(provider: .amazon) }

    /// The interface for authenticating a user with Bitbucket.
    var bitbucket: ThirdParty { .init(provider: .bitbucket) }

    /// The interface for authenticating a user with Coinbase.
    var coinbase: ThirdParty { .init(provider: .coinbase) }

    /// The interface for authenticating a user with Discord.
    var discord: ThirdParty { .init(provider: .discord) }

    /// The interface for authenticating a user with Facebook.
    var facebook: ThirdParty { .init(provider: .facebook) }

    /// The interface for authenticating a user with GitHub.
    var github: ThirdParty { .init(provider: .github) }

    /// The interface for authenticating a user with GitLab.
    var gitlab: ThirdParty { .init(provider: .gitlab) }

    /// The interface for authenticating a user with Google.
    var google: ThirdParty { .init(provider: .google) }

    /// The interface for authenticating a user with LinkedIn.
    var linkedin: ThirdParty { .init(provider: .linkedin) }

    /// The interface for authenticating a user with Microsoft.
    var microsoft: ThirdParty { .init(provider: .microsoft) }

    /// The interface for authenticating a user with Slack.
    var slack: ThirdParty { .init(provider: .slack) }

    /// The interface for authenticating a user with Twitch.
    var twitch: ThirdParty { .init(provider: .twitch) }
}
#endif

public extension StytchClient.OAuth {
    /// The dedicated parameters type for ``authenticate(parameters:)-172ak`` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case token, sessionDuration = "session_duration_minutes" }

        let token: String
        let sessionDuration: Minutes

        /// - Parameters:
        ///   - token: The token returned from the identity provider as parsed from the final/complete redirect URL.
        ///   - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
        public init(
            token: String,
            sessionDuration: Minutes = .defaultSessionDuration
        ) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }
}
