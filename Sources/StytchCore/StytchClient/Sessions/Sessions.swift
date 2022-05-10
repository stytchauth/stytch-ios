public extension StytchClient {
    /// The interface type for sessions.
    struct Sessions {
        let pathContext: Endpoint.Path = .init(rawValue: "sessions")

        /// An opaque token representing your current session, which your servers can check with Stytch's servers to verify your session status.
        public var sessionToken: Session.Token? { Current.sessionStorage.sessionToken }

        /// A session JWT (JSON Web Token), which your servers can check locally to verify your session status.
        public var sessionJwt: Session.Token? { Current.sessionStorage.sessionJwt }

        /// When using the `keychain` session storage strategy, this method must be called after any updated tokens are received
        /// from your backend to ensure the `StytchClient` and persistent storage are kept up-to-date.
        public func update(sessionTokens tokens: Session.Token...) {
            tokens.forEach(Current.sessionStorage.updatePersistentStorage)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResult>) {
            struct Parameters: Encodable {
                private enum CodingKeys: String, CodingKey { case sessionDurationMinutes, sessionToken, sessionJwt }

                let sessionDurationMinutes: Minutes
                let token: Session.Token

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(sessionDurationMinutes, forKey: .sessionDurationMinutes)
                    switch token.kind {
                    case .opaque:
                        try container.encode(token.value, forKey: .sessionToken)
                    case .jwt:
                        try container.encode(token.value, forKey: .sessionJwt)
                    }
                }
            }
            guard let token = sessionToken ?? sessionJwt else {
                completion(.success(.unauthenticated))
                return
            }

            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: Parameters(sessionDurationMinutes: parameters.duration, token: token)
            ) { (result: Result<AuthenticateResponse, Error>) in
                switch result.map(AuthenticateResult.authenticated) {
                case let .success(value):
                    completion(.success(value))
                case let .failure(error):
                    // TODO: Check if is StytchError and a 401 before clearing tokens
                    Current.sessionStorage.reset()
                    completion(.failure(error))
                }
            }
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func revoke(completion: @escaping Completion<BasicResponse>) {
            struct Parameters: Encodable {
                private enum CodingKeys: String, CodingKey { case sessionToken, sessionJwt }
                let token: Session.Token

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    switch token.kind {
                    case .opaque:
                        try container.encode(token.value, forKey: .sessionToken)
                    case .jwt:
                        try container.encode(token.value, forKey: .sessionJwt)
                    }
                }
            }
            guard let token = sessionToken ?? sessionJwt else {
                // TODO: - do something better than faking response
                completion(.success(.init(requestId: "", statusCode: 200)))
                return
            }
            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("revoke")),
                parameters: Parameters(token: token)
            ) { (result: Result<BasicResponse, Error>) in
                switch result {
                case let .success(value):
                    Current.sessionStorage.reset()
                    completion(.success(value))
                case let .failure(error):
                    // TODO: - Check if is StytchError and a 401 before clearing tokens
                    completion(.failure(error))
                }
            }
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
