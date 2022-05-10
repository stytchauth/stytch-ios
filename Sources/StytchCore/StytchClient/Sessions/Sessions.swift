public extension StytchClient {
    /// The interface type for sessions.
    struct Sessions {
        let pathContext: Endpoint.Path = .init(rawValue: "sessions")

        /// An opaque token representing your current session, which your servers can check with Stytch's servers to verify your session status.
        public var sessionToken: String? { Current.sessionStorage.sessionToken?.value }

        /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
        public var sessionJwt: String? { Current.sessionStorage.sessionJwt?.value }

        /// When using the `keychain` session storage strategy, this method must be called after any updated tokens are received
        /// from your backend to ensure the `StytchClient` and persistent storage are kept up-to-date.
        public func update(sessionTokens tokens: Session.Token...) {
            tokens.forEach(Current.sessionStorage.updatePersistentStorage)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResult>) {
            struct AuthParams: Encodable {
                let sessionDurationMinutes: Minutes
                let sessionToken: String
            }

            guard let sessionToken = sessionToken else {
                completion(.success(.unauthenticated))
                return
            }

            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: AuthParams(sessionDurationMinutes: parameters.duration, sessionToken: sessionToken),
                completion: { (result: Result<AuthenticateResponse, Error>) in
                    completion(result.map(AuthenticateResult.authenticated))
                }
            )
        }

        public func revoke(completion: @escaping Completion<BasicResponse>) {
            // TODO clear tokens in completion handler after calling revoke
        }

        public struct AuthenticateParameters: Encodable {
            public let duration: Minutes

            public init(duration: Minutes) {
                self.duration = duration
            }
        }

        public enum AuthenticateResult {
            case authenticated(AuthenticateResponse)
            case unauthenticated
        }
        /// The concrete response type for sessions `authenticate` calls.
        public typealias AuthenticateResponse = Response<AuthenticateResponseData>

        /// The underlying data for sessions `authenticate` calls. See ``SessionResponseType`` for more information.
        public struct AuthenticateResponseData: Decodable, SessionResponseType {
            public let sessionToken: String
            public let sessionJwt: String
            public let session: Session
        }
    }
}

public extension StytchClient {
    /// The interface implementation for sessions.
    static var sessions: Sessions { .init() }
}
