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
    var apple: Apple { .init(router: router.scopedRouter(OAuthRoute.apple)) }

    var facebook: GenericProvider { .init(provider: .facebook) }

    var google: GenericProvider { .init(provider: .google) }
}

extension StytchClient.OAuth {
    public struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case token, sessionDuration = "session_duration_minutes" }

        let token: String
        let sessionDuration: Minutes

        public init(
            token: String,
            sessionDuration: Minutes = .defaultSessionDuration
        ) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }
}

