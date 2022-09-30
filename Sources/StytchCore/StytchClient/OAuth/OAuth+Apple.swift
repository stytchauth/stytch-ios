import AuthenticationServices

public extension StytchClient.OAuth {
    /// docs
    struct Apple {
        let router: NetworkingRouter<OAuthRoute.AppleRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// docs
        public func start(parameters: StartParameters) async throws -> AuthenticateResponseType {
            let rawNonce = try Current.cryptoClient.dataWithRandomBytesOfCount(32).toHexString()
            let authenticateResult = try await Current.appleOAuthClient.authenticate(
                presentationContextProvider: parameters.presentationContextProvider,
                nonce: Current.cryptoClient.sha256(Data(rawNonce.utf8)).base64EncodedString()
            )
            return try await router.post(
                to: .authenticate,
                parameters: AuthenticateParameters(
                    idToken: authenticateResult.idToken,
                    nonce: rawNonce,
                    sessionDurationMinutes: parameters.sessionDuration,
                    name: authenticateResult.name
                )
            ) as AuthenticateResponse
        }
    }
}

public extension StytchClient.OAuth.Apple {
    struct StartParameters {
        let sessionDuration: Minutes
        let presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?

        public init(
            sessionDuration: Minutes = .defaultSessionDuration,
            presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil
        ) {
            self.sessionDuration = sessionDuration
            self.presentationContextProvider = presentationContextProvider
        }
    }
}

extension StytchClient.OAuth.Apple {
    struct AuthenticateParameters: Codable {
        let idToken: String
        let nonce: String
        let sessionDurationMinutes: Minutes
        let name: Name
    }

    struct Name: Codable {
        let firstName: String?
        let lastName: String?
    }
}
