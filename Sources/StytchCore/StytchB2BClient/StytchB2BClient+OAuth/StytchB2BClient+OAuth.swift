import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with OAuth products.
    static var oauth: OAuth {
        .init(router: router.scopedRouter {
            $0.oauthRoute
        })
    }
}

public extension StytchB2BClient {
    struct OAuth {
        let router: NetworkingRouter<StytchB2BClient.OAuthRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionStorage) private var sessionStorage

        // sourcery: AsyncVariants
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BMFAAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "b2b_oauth_failure", error: StytchSDKError.missingPKCE))
                throw StytchSDKError.missingPKCE
            }

            do {
                let intermediateSessionTokenParameters = IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionStorage.intermediateSessionToken,
                    wrapped: CodeVerifierParameters(
                        codingPrefix: .pkce,
                        codeVerifier: pkcePair.codeVerifier,
                        wrapped: parameters
                    )
                )

                let result = try await router.post(
                    to: .authenticate,
                    parameters: intermediateSessionTokenParameters
                ) as B2BMFAAuthenticateResponse
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "b2b_oauth_success"))
                return result
            } catch {
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "b2b_oauth_failure", error: error))
                throw error
            }
        }
    }
}

public extension StytchB2BClient.OAuth {
    struct AuthenticateParameters: Encodable {
        let oauthToken: String
        let sessionDurationMinutes: Minutes
        let locale: String?

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
            sessionDurationMinutes: Minutes = .defaultSessionDuration,
            locale: String? = nil
        ) {
            self.oauthToken = oauthToken
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
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
}
#endif
