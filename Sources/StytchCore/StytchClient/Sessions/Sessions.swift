public extension StytchClient {
    /// The interface type for sessions.
    struct Sessions {
        let pathContext: Endpoint.Path = "sessions"

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
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResult>) {
            guard let token = sessionToken ?? sessionJwt else {
                completion(.success(.unauthenticated))
                return
            }

            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: TokenizedParameters(parameters: parameters, token: token)
            ) { (result: Result<AuthenticateResponse, Error>) in
                switch result.map(AuthenticateResult.authenticated) {
                case let .success(value):
                    completion(.success(value))
                case let .failure(error):
                    Self.handleError(error)
                    completion(.failure(error))
                }
            }
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func revoke(completion: @escaping Completion<RevokeResult>) {
            guard let token = sessionToken ?? sessionJwt else {
                completion(.success(.unauthenticated))
                return
            }

            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("revoke")),
                parameters: TokenizedParameters(parameters: EmptyCodable(), token: token)
            ) { (result: Result<BasicResponse, Error>) in
                switch result {
                case let .success(value):
                    Current.sessionStorage.reset()
                    completion(.success(.authenticated(value)))
                case let .failure(error):
                    Self.handleError(error)
                    completion(.failure(error))
                }
            }
        }

        private static func handleError(_ error: Error) {
            if
                let error = error as? StytchGenericError,
                case let .network(statusCode) = error.origin,
                statusCode == 401
            {
                Current.sessionStorage.reset()
            } else if let error = error as? StytchStructuredError, error.statusCode == 401 {
                Current.sessionStorage.reset()
            }
        }

        public typealias AuthenticateResult = AuthenticationStatus<AuthenticateResponse>

        public typealias RevokeResult = AuthenticationStatus<BasicResponse>

        public enum AuthenticationStatus<T> {
            case authenticated(T)
            case unauthenticated
        }

        public struct AuthenticateParameters: Encodable {
            private enum CodingKeys: String, CodingKey { case duration = "session_duration_minutes" }

            public let duration: Minutes

            public init(duration: Minutes) {
                self.duration = duration
            }
        }

        struct TokenizedParameters<Parameters: Encodable>: Encodable {
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
}

public extension StytchClient {
    /// The interface implementation for sessions.
    static var sessions: Sessions { .init() }
}
