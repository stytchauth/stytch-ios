import Foundation

public extension StytchClient {
    /// OAuth allows you to leverage outside identity providers, for which your users may already have an account, to verify their identity. This is a low-friction method your users will be familiar with.
    struct OAuth {
        let router: NetworkingRouter<OAuthRoute>

        @Dependency(\.keychainClient)
        private var keychainClient

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            guard let codeVerifier: String = try keychainClient.get(.oauthPKCECodeVerifier) else {
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
    static var oauth: OAuth { .init(router: router.scopedRouter { $0.oauth }) }
}

public extension StytchClient.OAuth {
    /// The interface for authenticating a user with Apple.
    var apple: Apple { .init(router: router.scopedRouter { $0.apple }) }
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

    /// The interface for authenticating a user with Figma.
    var figma: ThirdParty { .init(provider: .figma) }

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

    /// The interface for authenticating a user with Snapchat.
    var snapchat: ThirdParty { .init(provider: .snapchat) }

    /// The interface for authenticating a user with Spotify.
    var spotify: ThirdParty { .init(provider: .spotify) }

    /// The interface for authenticating a user with TikTok.
    var tiktok: ThirdParty { .init(provider: .tiktok) }

    /// The interface for authenticating a user with Twitch.
    var twitch: ThirdParty { .init(provider: .twitch) }

    /// The interface for authenticating a user with Twitter.
    var twitter: ThirdParty { .init(provider: .twitter) }
}
#endif

public extension StytchClient.OAuth {
    /// The dedicated parameters type for ``authenticate(parameters:)-3tjwd`` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case token, sessionDuration = "sessionDurationMinutes" }

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
