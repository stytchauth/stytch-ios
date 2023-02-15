import AuthenticationServices

public extension StytchClient.OAuth {
    /// The SDK provides the ability to integrate with the natively-supported Sign In With Apple flow.
    struct Apple {
        let router: NetworkingRouter<OAuthRoute.AppleRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Initiates the OAuth flow by using the included parameters to start a Sign In With Apple request. If the authentication is successful this method will return a new session object.
        public func start(parameters: StartParameters) async throws -> AuthenticateResponse {
            let rawNonce = try Current.cryptoClient.dataWithRandomBytesOfCount(32).toHexString()
            let authenticateResult = try await Current.appleOAuthClient.authenticate(
                configureController: { controller in
                    #if !os(watchOS)
                    controller.presentationContextProvider = parameters.presentationContextProvider
                    #endif
                },
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
            )
        }
    }
}

public extension StytchClient.OAuth.Apple {
    /// The dedicated parameters type for ``StytchClient/OAuth-swift.struct/Apple-swift.struct/start(parameters:)-858tw`` calls.
    struct StartParameters {
        let sessionDuration: Minutes
        #if !os(watchOS)
        let presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
        #endif

        #if !os(watchOS)
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
        #else
        /// - Parameters:
        ///   - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
        public init(sessionDuration: Minutes = .defaultSessionDuration) {
            self.sessionDuration = sessionDuration
        }
        #endif
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
