import Foundation

public extension StytchClient {
    /// Docs
    struct Passwords {
        let pathContext: Endpoint.Path = "passwords"

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Docs
        public func create(parameters: PasswordParameters) async throws -> CreateResponse {
            try await StytchClient.post(
                to: .init(path: pathContext),
                parameters: parameters
            )
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Docs
        public func authenticate(parameters: PasswordParameters) async throws -> AuthenticateResponse {
            try await StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("authenticate")),
                parameters: parameters
            )
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Docs
        public func resetByEmailStart(parameters: ResetByEmailStartParameters) async throws -> BasicResponse {
            let (codeChallenge, codeChallengeMethod) = try StytchClient.generateAndStorePKCE()

            return try await StytchClient.post(
                to: .init(
                    path: pathContext
                        .appendingPathComponent("email")
                        .appendingPathComponent("reset")
                        .appendingPathComponent("start")
                ),
                parameters: CodeChallengedParameters(
                    codeChallenge: codeChallenge,
                    codeChallengeMethod: codeChallengeMethod,
                    wrapped: parameters
                )
            )
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Docs
        public func resetByEmail(parameters: ResetByEmailParameters) async throws -> AuthenticateResponse {
            guard let codeVerifier = try? Current.keychainClient.get(.stytchPasswordResetByEmailPKCECodeVerifier) else {
                throw StytchError.pckeNotAvailable
            }

            let response: AuthenticateResponse = try await StytchClient.post(
                to: .init(
                    path: pathContext
                        .appendingPathComponent("email")
                        .appendingPathComponent("reset")
                ),
                parameters: CodeVerifierParameters(codeVerifier: codeVerifier, wrapped: parameters)
            )

            try? Current.keychainClient.removeItem(.stytchPasswordResetByEmailPKCECodeVerifier)

            return response
        }

        // sourcery: AsyncAsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Docs
        public func strengthCheck(parameters: StrengthCheckParameters) async throws -> StrengthCheckResponse {
            try await StytchClient.post(
                to: .init(path: pathContext.appendingPathComponent("strength_check")),
                parameters: parameters
            )
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with passwords products.
    static var passwords: Passwords { .init() }
}

public extension StytchClient.Passwords {
    typealias CreateResponse = Response<CreateResponseData>
    typealias StrengthCheckResponse = Response<StrengthCheckResponseData>

    // TODO: add public init methods
    struct PasswordParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case email, password, sessionDuration = "session_duration_minutes" }

        let email: String
        let password: String
        let sessionDuration: Minutes
    }

    struct CreateResponseData: Codable {
        public let emailId: String
    }

    struct ResetByEmailStartParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case email
            case loginUrl = "login_redirect_url"
            case loginExpiration = "login_expiration_minutes"
            case resetPasswordUrl = "reset_password_redirect_url"
            case resetPasswordExpiration = "reset_password_expiration_minutes"
        }

        public let email: String
        public let loginUrl: URL?
        public let loginExpiration: Minutes?
        public let resetPasswordUrl: URL?
        public let resetPasswordExpiration: Minutes?
    }

    struct ResetByEmailParameters: Encodable {
        public let token: String
        public let password: String
    }

    struct StrengthCheckParameters: Encodable {
        let email: String?
        let password: String
    }

    struct StrengthCheckResponseData: Codable {
        public let validPassword: Bool
        public let score: Double
        public let breachedPassword: Bool
        public let feedback: Feedback

        public struct Feedback: Codable {
            public let suggestions: [String]
            public let warning: String
        }
    }
}
