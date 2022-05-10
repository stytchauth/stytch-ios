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
            struct AnyEncodable: Encodable {
                let value: Encodable

                func encode(to encoder: Encoder) throws {
                    try value.encode(to: encoder)
                }
            }
            let encodable: AnyEncodable
            if let sessionToken = sessionToken {
                struct AuthParams: Encodable {
                    let sessionDurationMinutes: Minutes
                    let sessionToken: String
                }
                encodable = AnyEncodable(value: AuthParams(sessionDurationMinutes: parameters.duration, sessionToken: sessionToken))
            } else if let sessionJwt = sessionJwt {
                struct AuthParams: Encodable {
                    let sessionDurationMinutes: Minutes
                    let sessionJwt: String
                }
                encodable = .init(value: AuthParams(sessionDurationMinutes: parameters.duration, sessionJwt: sessionJwt))
            } else {
                completion(.success(.unauthenticated))
                return
            }

            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: encodable,
                completion: { (result: Result<AuthenticateResponse, Error>) in
                    switch result.map(AuthenticateResult.authenticated) {
                    case let .success(value):
                        completion(.success(value))
                    case let .failure(error):
                        // TODO: Check if is StytchError and a 401 before clearing tokens
                        Current.sessionStorage.reset()
                        completion(.failure(error))
                    }
                }
            )
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
            guard let token = Current.sessionStorage.sessionToken ?? Current.sessionStorage.sessionJwt else {
                // TODO: - do something better than faking respond
                completion(.success(.init(requestId: "", statusCode: 200)))
                return
            }
            // TODO clear tokens in completion handler after calling revoke
            StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("revoke")),
                parameters: Parameters(token: token),
                completion: { (result: Result<BasicResponse, Error>) in
                    switch result {
                    case let .success(value):
                        Current.sessionStorage.reset()
                        completion(.success(value))
                    case let .failure(error):
                        // TODO: Check if is StytchError and a 401 before clearing tokens
                        completion(.failure(error))
                    }
                }
            )
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
