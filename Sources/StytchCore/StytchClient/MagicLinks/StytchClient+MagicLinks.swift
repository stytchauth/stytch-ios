public extension StytchClient {
    /// Magic links can be sent via email and allow for a quick and seamless login experience.
    struct MagicLinks {
        let router: NetworkingRouter<MagicLinksRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps the magic link [authenticate](https://stytch.com/docs/api/authenticate-magic-link) API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                throw StytchSDKError.missingPKCE
            }

            let authenticateResponse: AuthenticateResponse = try await router.post(
                to: .authenticate,
                parameters: CodeVerifierParameters(codeVerifier: pkcePair.codeVerifier, wrapped: parameters)
            )

            sessionManager.consumerLastAuthMethodUsed = .emailMagicLinks

            return authenticateResponse
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with magic-links products.
    static var magicLinks: MagicLinks { .init(router: router.scopedRouter { $0.magicLinks }) }
}

public extension StytchClient.MagicLinks {
    /// A dedicated parameters type for magic links `authenticate` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let token: String
        let sessionDurationMinutes: Minutes

        /**
         Initializes the parameters struct
         - Parameters:
           - token: The token extracted from the magic link.
           - sessionDurationMinutes: The duration, in minutes, for the requested session. Defaults to 5 minutes.
         */
        public init(token: String, sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration) {
            self.token = token
            self.sessionDurationMinutes = sessionDurationMinutes
        }
    }
}
