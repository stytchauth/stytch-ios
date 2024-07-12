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

        @Dependency(\.keychainClient) private var keychainClient
        @Dependency(\.pkcePairManager) private var pkcePairManager

        // sourcery: AsyncVariants
        /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BAuthenticateResponse {
            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "oauth_failure", error: StytchSDKError.missingPKCE))
                throw StytchSDKError.missingPKCE
            }
            do {
                let result = try await router.post(
                    to: .authenticate,
                    parameters: CodeVerifierParameters(codingPrefix: .pkce, codeVerifier: pkcePair.codeVerifier, wrapped: parameters)
                ) as B2BAuthenticateResponse
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "oauth_success"))
                return result
            } catch {
                try? await StytchB2BClient.events.logEvent(parameters: .init(eventName: "oauth_failure", error: error))
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
