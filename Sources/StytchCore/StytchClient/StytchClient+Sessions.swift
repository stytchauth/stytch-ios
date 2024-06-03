import Combine

public extension StytchClient {
    /// The interface for interacting with sessions products.
    static var sessions: StytchClientSessions {
        .init(router: router.scopedRouter { $0.sessions })
    }
}

enum SessionsRoute: String, RouteType {
    case authenticate
    case revoke

    var path: Path {
        .init(rawValue: rawValue)
    }
}

/// The SDK may be used to check whether a user has a cached session, view the current session, refresh the session, and revoke the session. To authenticate a session on your backend, you must use either the Stytch API or a Stytch server-side library. **NOTE**: - After a successful authentication, the session will be automatically refreshed in the background to ensure the sessionJwt remains valid (it expires after 5 minutes.) Session polling will be stopped after a session is revoked or after an unauthenticated error response is received.
public struct StytchClientSessions {
    let router: NetworkingRouter<SessionsRoute>
    @Dependency(\.sessionStorage) var sessionStorage
    @Dependency(\.localStorage) var localStorage

    /// If logged in, returns the cached session object.
    public var session: Session? {
        get {
            localStorage.session
        }
        set {
            localStorage.session = newValue
        }
    }

    /// An opaque token representing your session, which your servers can check with Stytch's servers to verify your session status.
    public var sessionToken: SessionToken? {
        sessionStorage.sessionToken
    }

    /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
    public var sessionJwt: SessionToken? {
        sessionStorage.sessionJwt
    }

    /// A publisher which emits following a change in authentication status and returns either the opaque session token or nil. You can use this as an indicator to set up or tear down your UI accordingly.
    public var onAuthChange: AnyPublisher<String?, Never> {
        sessionStorage.onAuthChange.eraseToAnyPublisher()
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid, returning both an opaque sessionToken and sessionJwt for this session. The sessionJwt will have a fixed lifetime of five minutes regardless of the underlying session duration, though it will be refreshed automatically in the background after a successful authentication.
    public func authenticate(parameters: Sessions.AuthenticateParameters) async throws -> AuthenticateResponse {
        try await router.post(to: .authenticate, parameters: parameters)
    }

    /// If your app has cookies disabled or simply receives updated session tokens from your backend via means other than
    /// `Set-Cookie` headers, you must call this method after receiving the updated tokens to ensure the `StytchClient`
    /// and persistent storage are kept up-to-date. You should include both the opaque token and the jwt.
    public func update(sessionTokens tokens: [SessionToken]) {
        tokens.forEach(sessionStorage.updatePersistentStorage)
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
    public func revoke(parameters: Sessions.RevokeParameters = .init()) async throws -> BasicResponse {
        do {
            let response: BasicResponse = try await router.post(to: .revoke, parameters: EmptyCodable())
            sessionStorage.reset()
            return response
        } catch {
            if parameters.forceClear { sessionStorage.reset() }
            throw error
        }
    }
}
