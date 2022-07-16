public extension StytchClient {
    /// The SDK may be used to check whether a user has a cached session, view the current session, refresh the session, and revoke the session. To authenticate a session on your backend, you must use either the Stytch API or a Stytch server-side library. **NOTE**: - After a successful authentication, the session will be automatically refreshed in the background to ensure the sessionJwt remains valid (it expires after 5 minutes.) Session polling will be stopped after a session is revoked or after an unauthenticated error response is received.
    struct Sessions {
        let pathContext: Endpoint.Path = "sessions"

        /// If logged in, returns the cached session object.
        public var session: Session? { Current.sessionStorage.session }

        /// An opaque token representing your current session, which your servers can check with Stytch's servers to verify your session status.
        public var sessionToken: Session.Token? { Current.sessionStorage.sessionToken }

        /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
        public var sessionJwt: Session.Token? { Current.sessionStorage.sessionJwt }

        /// If your app has cookies disabled or simply receives updated session tokens from your backend via means other than
        /// `Set-Cookie` headers, you must call this method after receiving the updated tokens to ensure the `StytchClient`
        /// and persistent storage are kept up-to-date. You should include both the opaque token and the jwt.
        public func update(sessionTokens tokens: [Session.Token]) {
            tokens.forEach(Current.sessionStorage.updatePersistentStorage)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid, returning both an opaque sessionToken and sessionJwt for this session. The sessionJwt will have a fixed lifetime of five minutes regardless of the underlying session duration, though it will be refreshed automatically in the background after a successful authentication.
        public func authenticate(parameters: AuthenticateParameters) async throws -> SessionsAuthenticateResponse {
            guard let token = sessionToken ?? sessionJwt else {
                return .unauthenticated
            }

            return try await .authenticated(
                StytchClient.post(
                    to: .init(path: pathContext.appendingPathComponent("authenticate")),
                    parameters: TokenizedParameters(parameters: parameters, token: token)
                )
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
        public func revoke() async throws -> SessionsRevokeResponse {
            guard let token = sessionToken ?? sessionJwt else {
                return .unauthenticated
            }

            let response: BasicResponse = try await StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("revoke")),
                parameters: TokenizedParameters(parameters: EmptyCodable(), token: token)
            )
            Current.sessionStorage.reset()
            return .authenticated(response)
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with sessions products.
    static var sessions: Sessions { .init() }
}

public extension StytchClient.Sessions {
    /// A ``AuthenticationStatus``-wrapped ``AuthenticateResponse``
    typealias SessionsAuthenticateResponse = AuthenticationStatus<AuthenticateResponse>

    /// A ``AuthenticationStatus``-wrapped ``BasicResponse``
    typealias SessionsRevokeResponse = AuthenticationStatus<BasicResponse>

    /// A generic type which represents the authentication status of the user prior to the method call.
    enum AuthenticationStatus<T> {
        case authenticated(T)
        case unauthenticated
    }

    /// The dedicated parameters type for sessions `authenticate` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case sessionDuration = "session_duration_minutes" }

        let sessionDuration: Minutes?

        /// - Parameter sessionDuration: The duration, in minutes, of the requested session. If included, this value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the SDK Configuration page of the Stytch dashboard. Defaults to nil, leaving the original session expiration intact.
        public init(sessionDuration: Minutes? = nil) {
            self.sessionDuration = sessionDuration
        }
    }

    internal struct TokenizedParameters<Parameters: Encodable>: Encodable {
        private enum CodingKeys: String, CodingKey { case sessionToken, sessionJwt }

        let parameters: Parameters
        let token: Session.Token

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try parameters.encode(to: encoder)

            switch token.kind {
            case .opaque:
                try container.encode(token.value, forKey: .sessionToken)
            case .jwt:
                try container.encode(token.value, forKey: .sessionJwt)
            }
        }
    }
}
