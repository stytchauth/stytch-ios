import Combine

public extension StytchB2BClient {
    /// The interface for interacting with sessions products.
    static var sessions: Sessions {
        .init(router: router.scopedRouter { $0.sessions })
    }
}

public extension StytchB2BClient {
    /// The SDK may be used to check whether a user has a cached session, view the current session, refresh the session, and revoke the session. To authenticate a session on your backend, you must use either the Stytch API or a Stytch server-side library. **NOTE**: - After a successful authentication, the session will be automatically refreshed in the background to ensure the sessionJwt remains valid (it expires after 5 minutes.) Session polling will be stopped after a session is revoked or after an unauthenticated error response is received.
    struct Sessions {
        let router: NetworkingRouter<StytchB2BClient.SessionsRoute>
        @Dependency(\.memberSessionStorage) var memberSessionStorage
        @Dependency(\.sessionManager) var sessionManager

        public var memberSession: MemberSession? {
            memberSessionStorage.object
        }

        /// An opaque token representing your session, which your servers can check with Stytch's servers to verify your session status.
        public var sessionToken: SessionToken? {
            sessionManager.sessionToken
        }

        /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
        public var sessionJwt: SessionToken? {
            sessionManager.sessionJwt
        }

        /// A publisher which emits following a change in authentication status and returns either the opaque session token or nil. You can use this as an indicator to set up or tear down your UI accordingly.
        public var onMemberSessionChange: AnyPublisher<StytchObjectInfo<MemberSession>, Never> {
            memberSessionStorage.onChange
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid, returning both an opaque sessionToken and sessionJwt for this session. The sessionJwt will have a fixed lifetime of five minutes regardless of the underlying session duration, though it will be refreshed automatically in the background after a successful authentication.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BAuthenticateResponse {
            try await router.post(to: .authenticate, parameters: parameters)
        }

        /// If your app has cookies disabled or simply receives updated session tokens from your backend via means other than
        /// `Set-Cookie` headers, you must call this method after receiving the updated tokens to ensure the `StytchClient`
        /// and persistent storage are kept up-to-date. You are required to include both the opaque token and the jwt.
        public func update(sessionTokens: SessionTokens) {
            sessionManager.updatePersistentStorage(tokens: sessionTokens)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
        public func revoke(parameters: RevokeParameters = .init()) async throws -> BasicResponse {
            do {
                let response: BasicResponse = try await router.post(to: .revoke, parameters: EmptyCodable())
                sessionManager.resetSession()
                return response
            } catch {
                if parameters.forceClear { sessionManager.resetSession() }
                throw error
            }
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Use this endpoint to exchange a Member's existing session for another session in a different Organization.
        public func exchange(parameters: ExchangeParameters) async throws -> B2BMFAAuthenticateResponse {
            try await router.post(to: .exchange, parameters: parameters)
        }
    }
}

public extension StytchB2BClient.Sessions {
    /// The dedicated parameters type for sessions `authenticate` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let sessionDurationMinutes: Minutes?

        /// - Parameter sessionDurationMinutes: The duration, in minutes, of the requested session.
        /// If included, this value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the SDK Configuration page of the Stytch dashboard.
        /// Defaults to nil, leaving the original session expiration intact.
        public init(sessionDurationMinutes: Minutes? = nil) {
            self.sessionDurationMinutes = sessionDurationMinutes
        }
    }

    /// The dedicated parameters type for session `revoke` calls.
    struct RevokeParameters {
        let forceClear: Bool

        /// - Parameter forceClear: In the event of an error received from the network, setting this value to true will ensure the local session state is cleared.
        public init(forceClear: Bool = false) {
            self.forceClear = forceClear
        }
    }

    /// The dedicated parameters type for session `exchange` calls.
    struct ExchangeParameters: Codable, Sendable {
        /// The ID of the organization that the new session should belong to.
        public let organizationID: String
        /// The duration, in minutes, for the requested session. Defaults to 5 minutes.
        public let sessionDurationMinutes: Minutes
        /// The locale will be used if an OTP code is sent to the member's phone number as part of a secondary authentication requirement.
        public let locale: StytchLocale?

        public init(organizationID: String, sessionDurationMinutes: Minutes = .defaultSessionDuration, locale: StytchLocale? = nil) {
            self.organizationID = organizationID
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}
