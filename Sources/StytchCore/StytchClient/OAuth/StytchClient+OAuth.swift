import Foundation

public protocol OAuthProviderProtocol {
    func authenticate(parameters: StytchClient.OAuth.AuthenticateParameters) async throws -> StytchClient.OAuth.OAuthAuthenticateResponse
}

public extension StytchClient {
    /// OAuth allows you to leverage outside identity providers, for which your users may already have an account, to verify their identity. This is a low-friction method your users will be familiar with.
    struct OAuth: OAuthProviderProtocol {
        let router: NetworkingRouter<OAuthRoute>
        let userRouter: NetworkingRouter<UsersRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: AuthenticateParameters) async throws -> OAuthAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                try? await EventsClient.logEvent(parameters: .init(eventName: "oauth_failure", error: StytchSDKError.missingPKCE))
                throw StytchSDKError.missingPKCE
            }

            do {
                let oauthAuthenticateResponse = try await router.post(
                    to: .authenticate,
                    parameters: CodeVerifierParameters(codeVerifier: pkcePair.codeVerifier, wrapped: parameters)
                ) as OAuthAuthenticateResponse
                try? await EventsClient.logEvent(parameters: .init(eventName: "oauth_success"))
                sessionManager.consumerLastAuthMethodUsed = .oauth
                return oauthAuthenticateResponse
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "oauth_failure", error: error))
                throw error
            }
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with OAuth products.
    static var oauth: OAuth { .init(router: router.scopedRouter { $0.oauth }, userRouter: router.scopedRouter { $0.users }) }
}

public extension StytchClient.OAuth {
    /// The interface for authenticating a user with Apple.
    var apple: Apple { .init(router: router.scopedRouter { $0.apple }, userRouter: userRouter) }
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

    /// The interface for authenticating a user with Salesforce.
    var salesforce: ThirdParty { .init(provider: .salesforce) }

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

    /// The interface for authenticating a user with Yahoo.
    var yahoo: ThirdParty { .init(provider: .yahoo) }
}
#endif

public extension StytchClient.OAuth {
    /// The dedicated parameters type for ``authenticate(parameters:)-3tjwd`` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let token: String
        let sessionDurationMinutes: Minutes

        /// - Parameters:
        ///   - token: The token returned from the identity provider as parsed from the final/complete redirect URL.
        ///   - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        public init(
            token: String,
            sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration
        ) {
            self.token = token
            self.sessionDurationMinutes = sessionDurationMinutes
        }
    }
}

public extension StytchClient.OAuth {
    /// The concrete response type for OAuth `authenticate` calls.
    typealias OAuthAuthenticateResponse = Response<OAuthAuthenticateResponseData>

    struct OAuthAuthenticateResponseData: Codable, Sendable, AuthenticateResponseDataType {
        /// The current user object.
        public let user: User
        /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
        public let sessionToken: String
        /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
        public let sessionJwt: String
        /// The ``Session`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let session: Session
        /// The visitor_id (a unique identifier) of the user's device. See the Device Fingerprinting documentation for more details on the visitor_id.
        public let userDevice: DeviceHistory?
        /// The unique ID for an OAuth registration.
        public let oauthUserRegistrationId: String
        /// The unique identifier for the User within a given OAuth provider. Also commonly called the "sub" or "Subject field" in OAuth protocols.
        public let providerSubject: String
        /// Denotes the OAuth identity provider that the user has authenticated with, e.g. Google, Facebook, GitHub etc.
        public let providerType: String
        /// The provider_values object lists relevant identifiers, values, and scopes for a given OAuth provider.
        /// For example this object will include a provider's access_token that you can use to access the provider's API for a given user.
        /// Note that these values will vary based on the OAuth provider in question, e.g. id_token is only returned by OIDC compliant identity providers.
        public let providerValues: OAuthProviderValues
    }
}
