import Foundation

public protocol B2BOAuthProviderProtocol {
    func authenticate(parameters: StytchB2BClient.OAuth.AuthenticateParameters) async throws -> StytchB2BClient.OAuth.OAuthAuthenticateResponse
}

public extension StytchB2BClient {
    /// The interface for interacting with OAuth products.
    static var oauth: OAuth {
        .init(router: router.scopedRouter {
            $0.oauth
        })
    }
}

public extension StytchB2BClient {
    struct OAuth: B2BOAuthProviderProtocol {
        let router: NetworkingRouter<StytchB2BClient.OAuthRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: AuthenticateParameters) async throws -> OAuthAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                try? await EventsClient.logEvent(parameters: .init(eventName: "b2b_oauth_failure", error: StytchSDKError.missingPKCE))
                throw StytchSDKError.missingPKCE
            }

            do {
                let intermediateSessionTokenParameters = IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: CodeVerifierParameters(
                        codingPrefix: .pkce,
                        codeVerifier: pkcePair.codeVerifier,
                        wrapped: parameters
                    )
                )

                let oauthAuthenticateResponse = try await router.post(
                    to: .authenticate,
                    parameters: intermediateSessionTokenParameters,
                    useDFPPA: true
                ) as OAuthAuthenticateResponse
                try? await EventsClient.logEvent(parameters: .init(eventName: "b2b_oauth_success"))
                sessionManager.b2bLastAuthMethodUsed = .oauth
                return oauthAuthenticateResponse
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "b2b_oauth_failure", error: error))
                throw error
            }
        }
    }
}

public extension StytchB2BClient.OAuth {
    struct AuthenticateParameters: Encodable, Sendable {
        let oauthToken: String
        let sessionDurationMinutes: Minutes
        let locale: StytchLocale

        /// - Parameters:
        ///   - oauthToken: The token to authenticate.
        ///   - sessionDurationMinutes: Set the session lifetime to be this many minutes from now. This will start a new session if one doesn't already exist, returning both an opaque session_token and session_jwt for this session. Remember that the session_jwt will have a fixed lifetime of five minutes regardless of the underlying session duration, and will need to be refreshed over time.
        ///     This value must be a minimum of 5 and a maximum of 527040 minutes (366 days).
        ///     If a session_token or session_jwt is provided then a successful authentication will continue to extend the session this many minutes.
        ///     If the session_duration_minutes parameter is not specified, a Stytch session will be created with a 60 minute duration. If you don't want to use the Stytch session product, you can ignore the session fields in the response.
        ///   - locale: If the Member needs to complete an MFA step, and the Member has a phone number, this endpoint will pre-emptively send a one-time passcode (OTP) to the Member's phone number. The locale argument will be used to determine which language to use when sending the passcode.
        ///     Parameter is a IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        ///     Request support for additional languages here (https://docs.google.com/forms/d/e/1FAIpQLScZSpAu_m2AmLXRT3F3kap-s_mcV6UTBitYn6CdyWP0-o7YjQ/viewform?usp=sf_link%22)!
        public init(
            oauthToken: String,
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            locale: StytchLocale = .en
        ) {
            self.oauthToken = oauthToken
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.OAuth {
    /// The concrete response type for B2B OAuth `authenticate` calls.
    typealias OAuthAuthenticateResponse = Response<OAuthAuthenticateResponseData>

    struct OAuthAuthenticateResponseData: Codable, Sendable, B2BMFAAuthenticateResponseDataType {
        /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let memberSession: MemberSession?
        /// The current member's ID.
        public let memberId: Member.ID
        /// The current member object.
        public let member: Member
        /// The current organization object.
        public let organization: Organization
        /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
        public let sessionToken: String
        /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
        public let sessionJwt: String
        /// An optional intermediate session token to be returned if multi factor authentication is enabled
        public let intermediateSessionToken: String?
        /// Indicates whether the Member is fully authenticated. If false, the Member needs to complete an MFA step to log in to the Organization.
        public let memberAuthenticated: Bool
        /// Information about the MFA requirements of the Organization and the Member's options for fulfilling MFA.
        public let mfaRequired: StytchB2BClient.MFARequired?
        /// Information about the primary authentication requirements of the Organization.
        public let primaryRequired: StytchB2BClient.PrimaryRequired?
        /// If a valid telemetry_id was passed in the request and the Fingerprint Lookup API returned results, the member_device response field will contain information about the member's device attributes.
        public let memberDevice: DeviceHistory?
        /// The provider_values object lists relevant identifiers, values, and scopes for a given OAuth provider.
        /// For example this object will include a provider's access_token that you can use to access the provider's API for a given user.
        /// Note that these values will vary based on the OAuth provider in question, e.g. id_token is only returned by OIDC compliant identity providers.
        public let providerValues: OAuthProviderValues
    }
}

#if !os(watchOS)
public extension StytchB2BClient.OAuth {
    /// The interface for authenticating a user with Google.
    var google: ThirdParty {
        .init(provider: .google)
    }

    /// The interface for authenticating a user with Microsoft.
    var microsoft: ThirdParty {
        .init(provider: .microsoft)
    }

    /// The interface for authenticating a user with Hubspot.
    var hubspot: ThirdParty {
        .init(provider: .hubspot)
    }

    /// The interface for authenticating a user with Slack.
    var slack: ThirdParty {
        .init(provider: .slack)
    }

    /// The interface for authenticating a user with Github.
    var github: ThirdParty {
        .init(provider: .github)
    }
}
#endif
