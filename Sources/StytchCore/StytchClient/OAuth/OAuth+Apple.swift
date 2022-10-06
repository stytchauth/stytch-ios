import AuthenticationServices

public extension StytchClient.OAuth {
    /// The SDK provides the ability to integrate with the natively-supported Sign In With Apple flow.
    struct Apple {
        let router: NetworkingRouter<OAuthRoute.AppleRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Initiates the OAuth flow by using the included parameters to start a Sign In With Apple request. If the authentication is successful this method will return a new session object.
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
    /// The dedicated parameters type for ``start(parameters:)`` calls.
    struct StartParameters {
        let sessionDuration: Minutes
        let presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?

        /// - Parameters:
        ///   - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
        ///   - presentationContextProvider: This native Apple authorization type allows you to present Sign In With Apple in the window of your choosing.
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
