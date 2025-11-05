import AuthenticationServices

public protocol AppleOAuthProviderProtocol {
    func start(parameters: StytchClient.OAuth.Apple.StartParameters) async throws -> StytchClient.OAuth.Apple.AuthenticateResponse
}

public extension StytchClient.OAuth {
    /// The SDK provides the ability to integrate with the natively-supported Sign In With Apple flow.
    struct Apple: AppleOAuthProviderProtocol {
        let router: NetworkingRouter<OAuthRoute.AppleRoute>
        let userRouter: NetworkingRouter<UsersRoute>

        @Dependency(\.cryptoClient) private var cryptoClient
        @Dependency(\.appleOAuthClient) private var appleOAuthClient
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Initiates the OAuth flow by using the included parameters to start a Sign In With Apple request. If the authentication is successful this method will return a new session object.
        public func start(parameters: StartParameters) async throws -> AuthenticateResponse {
            let rawNonce = try cryptoClient.dataWithRandomBytesOfCount(32).toHexString()

            let authenticateResult = try await appleOAuthClient.authenticate(
                configureController: { controller in
                    #if !os(watchOS)
                    controller.presentationContextProvider = parameters.presentationContextProvider
                    #endif
                },
                nonce: cryptoClient.sha256(Data(rawNonce.utf8)).base64EncodedString()
            )

            let authenticateResponse: AuthenticateResponse = try await router.post(
                to: .authenticate,
                parameters: AuthenticateParameters(
                    idToken: authenticateResult.idToken,
                    nonce: rawNonce,
                    sessionDurationMinutes: parameters.sessionDurationMinutes
                )
            )

            if authenticateResult.name != nil {
                let _: BasicResponse = try await userRouter.put(
                    to: .index,
                    parameters: StytchClient.UserManagement.UpdateParameters(
                        name: authenticateResult.name
                    )
                )
            }

            _ = try await EventsClient.logEvent(
                parameters: .init(
                    eventName: "apple_oauth_name_found",
                    details: [
                        "found": (authenticateResult.name != nil).description,
                    ]
                )
            )

            sessionManager.consumerLastAuthMethodUsed = .oauthApple

            return authenticateResponse
        }
    }
}

public extension StytchClient.OAuth.Apple {
    /// The concrete response type for Sign In With Apple `authenticate` calls.
    typealias AuthenticateResponse = Response<AuthenticateResponseData>

    /// The underlying data for Sign In With Apple `authenticate` calls.
    struct AuthenticateResponseData: Codable, Sendable, AuthenticateResponseDataType {
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
        /// Indicates if this is a new or returning user
        public let userCreated: Bool
    }

    /// The dedicated parameters type for ``StytchClient/OAuth-swift.struct/Apple-swift.struct/start(parameters:)-5rxqg`` calls.
    struct StartParameters {
        let sessionDurationMinutes: Minutes

        #if !os(watchOS)
        let presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
        #endif

        #if !os(watchOS)
        /// - Parameters:
        ///   - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        ///   - presentationContextProvider: This native Apple authorization type allows you to present Sign In With Apple in the window of your choosing.
        public init(
            sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration,
            presentationContextProvider: ASAuthorizationControllerPresentationContextProviding? = nil
        ) {
            self.sessionDurationMinutes = sessionDurationMinutes
            self.presentationContextProvider = presentationContextProvider
        }

        #else

        /// - Parameters:
        ///   - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        public init(sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration) {
            self.sessionDurationMinutes = sessionDurationMinutes
        }
        #endif
    }
}

extension StytchClient.OAuth.Apple {
    struct AuthenticateParameters: Codable, Sendable {
        let idToken: String
        let nonce: String
        let sessionDurationMinutes: Minutes
    }

    struct Name: Codable, Sendable {
        let firstName: String?
        let lastName: String?
    }
}
