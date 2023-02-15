/// The SDK may be used to check whether a user has a cached session, view the current session, refresh the session, and revoke the session. To authenticate a session on your backend, you must use either the Stytch API or a Stytch server-side library. **NOTE**: - After a successful authentication, the session will be automatically refreshed in the background to ensure the sessionJwt remains valid (it expires after 5 minutes.) Session polling will be stopped after a session is revoked or after an unauthenticated error response is received.
public struct Sessions<AuthResponseType: Decodable> {
    let router: NetworkingRouter<SessionsRoute>

    /// An opaque token representing your current session, which your servers can check with Stytch's servers to verify your session status.
    public var sessionToken: SessionToken? { Current.sessionStorage.sessionToken }

    /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
    public var sessionJwt: SessionToken? { Current.sessionStorage.sessionJwt }

    /// If your app has cookies disabled or simply receives updated session tokens from your backend via means other than
    /// `Set-Cookie` headers, you must call this method after receiving the updated tokens to ensure the `StytchClient`
    /// and persistent storage are kept up-to-date. You should include both the opaque token and the jwt.
    public func update(sessionTokens tokens: [SessionToken]) {
        tokens.forEach(Current.sessionStorage.updatePersistentStorage)
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid, returning both an opaque sessionToken and sessionJwt for this session. The sessionJwt will have a fixed lifetime of five minutes regardless of the underlying session duration, though it will be refreshed automatically in the background after a successful authentication.
    public func authenticate(parameters: AuthenticateParameters) async throws -> AuthResponseType {
        try await router.post(to: .authenticate, parameters: parameters)
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
    public func revoke() async throws -> BasicResponse {
        defer { Current.sessionStorage.reset() }
        return try await router.post(to: .revoke, parameters: EmptyCodable())
    }
}

public extension Sessions where AuthResponseType == B2BAuthenticateResponse {
    internal(set) var memberSession: MemberSession? {
        get { Current.localStorage.memberSession }
        set { Current.localStorage.memberSession = newValue }
    }
}

public extension Sessions where AuthResponseType == AuthenticateResponse {
    /// If logged in, returns the cached session object.
    internal(set) var session: Session? {
        get { Current.localStorage.session }
        set { Current.localStorage.session = newValue }
    }
}

public extension StytchClient {
    /// The interface for interacting with sessions products.
    static var sessions: Sessions<AuthenticateResponse> { .init(router: router.scopedRouter { $0.sessions }) }
}

public extension Sessions {
    /// The dedicated parameters type for sessions `authenticate` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case sessionDuration = "sessionDurationMinutes" }

        let sessionDuration: Minutes?

        /// - Parameter sessionDuration: The duration, in minutes, of the requested session. If included, this value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the SDK Configuration page of the Stytch dashboard. Defaults to nil, leaving the original session expiration intact.
        public init(sessionDuration: Minutes? = nil) {
            self.sessionDuration = sessionDuration
        }
    }
}
