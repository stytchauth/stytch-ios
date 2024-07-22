import Foundation

public protocol PasswordsProtocol {
    func create(parameters: StytchClient.Passwords.PasswordParameters) async throws -> StytchClient.Passwords.CreateResponse
    func authenticate(parameters: StytchClient.Passwords.PasswordParameters) async throws -> AuthenticateResponse
    func resetByEmailStart(parameters: StytchClient.Passwords.ResetByEmailStartParameters) async throws -> BasicResponse
    func resetByEmail(parameters: StytchClient.Passwords.ResetByEmailParameters) async throws -> AuthenticateResponse
    func strengthCheck(parameters: StytchClient.Passwords.StrengthCheckParameters) async throws -> StytchClient.Passwords.StrengthCheckResponse
    func resetBySession(parameters: StytchClient.Passwords.ResetBySessionParameters) async throws -> AuthenticateResponse
    func resetByExistingPassword(parameters: StytchClient.Passwords.ResetByExistingPasswordParameters) async throws -> AuthenticateResponse
}

public extension StytchClient {
    /// Stytch supports creating, storing, and authenticating password based users, as well as support for account recovery (password reset) and account deduplication with passwordless login methods.
    /// Our implementation of passwords has built-in breach detection powered by [HaveIBeenPwned](https://haveibeenpwned.com/) on both sign-up and login, to prevent the use of compromised credentials and uses Dropbox’s [zxcvbn](https://github.com/dropbox/zxcvbn) strength requirements to guide users towards creating passwords that are easy for humans to remember but difficult for computers to crack.
    struct Passwords: PasswordsProtocol {
        let router: NetworkingRouter<PasswordsRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Create a new user with a password and an authenticated session for the user if requested. If a user with this email already exists in the project, an error will be returned.
        ///
        /// Existing passwordless users who wish to create a password need to go through the reset password flow.
        public func create(parameters: PasswordParameters) async throws -> CreateResponse {
            try await router.post(to: .create, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Authenticate a user with their email address and password. This method verifies that the user has a password currently set, and that the entered password is correct.
        ///
        /// There are two instances where the endpoint will return a reset_password error even if they enter their previous password:
        /// 1. The user’s credentials appeared in the HaveIBeenPwned dataset.
        ///   a. We force a password reset to ensure that the user is the legitimate owner of the email address, and not a malicious actor abusing the compromised credentials.
        /// 2. The user used email based authentication (e.g. Magic Links, Google OAuth) for the first time, and had not previously verified their email address for password based login.
        ///   a. We force a password reset in this instance in order to safely deduplicate the account by email address, without introducing the risk of a pre-hijack account takeover attack.
        public func authenticate(parameters: PasswordParameters) async throws -> AuthenticateResponse {
            try await router.post(to: .authenticate, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Initiates a password reset for the email address provided. This will trigger an email to be sent to the address, containing a magic link that will allow them to set a new password and authenticate.
        public func resetByEmailStart(parameters: ResetByEmailStartParameters) async throws -> BasicResponse {
            let pkcePair = try pkcePairManager.generateAndReturnPKCECodePair()

            return try await router.post(
                to: .resetByEmail(.start),
                parameters: CodeChallengedParameters(
                    codeChallenge: pkcePair.codeChallenge,
                    codeChallengeMethod: pkcePair.method,
                    wrapped: parameters
                )
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Reset the user’s password and authenticate them. This endpoint checks that the magic link token is valid, hasn’t expired, or already been used – and can optionally require additional security settings, such as the IP address and user agent matching the initial reset request.
        ///
        /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the user is authenticated.
        public func resetByEmail(parameters: ResetByEmailParameters) async throws -> AuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                throw StytchSDKError.missingPKCE
            }

            let response: AuthenticateResponse = try await router.post(
                to: .resetByEmail(.complete),
                parameters: CodeVerifierParameters(codeVerifier: pkcePair.codeVerifier, wrapped: parameters)
            )

            return response
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// This method allows you to check whether or not the user’s provided password is valid, and to provide feedback to the user on how to increase the strength of their password.
        ///
        /// Passwords are considered invalid if either of the following is true:
        ///
        /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2.
        /// 2. The password is present in the HaveIBeenPwned dataset.
        ///
        /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password. If you do not pass the email, it is possible that the password will evaluate as valid – but will fail with a weak_password error when used in the ``StytchClient/Passwords-swift.struct/create(parameters:)-3gtlz`` method.
        /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors that feedback provided by the zxcvbn library.
        public func strengthCheck(parameters: StrengthCheckParameters) async throws -> StrengthCheckResponse {
            try await router.post(to: .strengthCheck, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// This method resets the user’s password using their existing session. The endpoint will error if the session does not have a password, email magic link, or email OTP authentication factor that has been issued within the last 5 minutes.
        ///
        /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the user is authenticated.
        public func resetBySession(parameters: ResetBySessionParameters) async throws -> AuthenticateResponse {
            try await router.post(to: .resetBySession, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// This method resets the user’s password using their existing password. This endpoint checks that the existing password matches the stored value.
        ///
        /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the user is authenticated.
        public func resetByExistingPassword(parameters: ResetByExistingPasswordParameters) async throws -> AuthenticateResponse {
            try await router.post(to: .resetByExistingPassword, parameters: parameters)
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with passwords products.
    static var passwords: Passwords { .init(router: router.scopedRouter { $0.passwords }) }
}

public extension StytchClient.Passwords {
    /// The concrete response type for passwords `create` calls.
    typealias CreateResponse = Response<CreateResponseData>

    /// The underlying data for passwords `create` calls.
    struct CreateResponseData: Decodable, AuthenticateResponseDataType {
        public let emailId: User.Email.ID
        public let userId: User.ID
        public let user: User
        public let sessionToken: String
        public let sessionJwt: String
        public let session: Session
    }

    /// The dedicated parameters type for password `create` and `authenticate` calls.
    struct PasswordParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case email, password, sessionDuration = "sessionDurationMinutes" }

        let email: String
        let password: String
        let sessionDuration: Minutes

        ///  - Parameters:
        ///    - email: The user's email address.
        ///    - password: The user's password.
        ///    - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
        public init(email: String, password: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.email = email
            self.password = password
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.Passwords {
    /// The dedicated parameters type for passwords `resetByEmailStart` calls.
    struct ResetByEmailStartParameters: Encodable, Equatable {
        public static func == (
            lhs: ResetByEmailStartParameters,
            rhs: ResetByEmailStartParameters
        ) -> Bool {
            lhs.email == rhs.email &&
                lhs.loginUrl == rhs.loginUrl &&
                lhs.loginExpiration?.rawValue == rhs.loginExpiration?.rawValue &&
                lhs.resetPasswordUrl == rhs.resetPasswordUrl &&
                lhs.resetPasswordExpiration?.rawValue == rhs.resetPasswordExpiration?.rawValue &&
                lhs.resetPasswordTemplateId == rhs.resetPasswordTemplateId
        }

        private enum CodingKeys: String, CodingKey {
            case email
            case loginUrl = "loginRedirectUrl"
            case loginExpiration = "loginExpirationMinutes"
            case resetPasswordUrl = "resetPasswordRedirectUrl"
            case resetPasswordExpiration = "resetPasswordExpirationMinutes"
            case resetPasswordTemplateId
        }

        public let email: String
        public let loginUrl: URL?
        public let loginExpiration: Minutes?
        public let resetPasswordUrl: URL?
        public let resetPasswordExpiration: Minutes?
        public let resetPasswordTemplateId: String?

        /// - Parameters:
        ///   - email: The user's email address.
        ///   - loginUrl: The url that the user clicks from the password reset email to skip resetting their password and directly login. This should be a url that your app receives, parses, and subsequently send an API request to complete the password reset process. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
        ///   - loginExpiration: Set the expiration for the direct login link, in minutes. By default, it expires in 1 hour. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
        ///   - resetPasswordUrl: The url that the user clicks from the password reset email to finish the reset password flow. This should be a url that your app receives and parses and subsequently send an API request to authenticate the magic link and log in the user. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
        ///   - resetPasswordExpiration: Set the expiration for the password reset, in minutes. By default, it expires in 1 hour. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
        ///   - resetPasswordTemplateId: Use a custom template for password reset emails. By default, it will use your default email template. The template must be a template using our built-in customizations or a custom HTML email for Passwords - Password reset.
        public init(
            email: String,
            loginUrl: URL? = nil,
            loginExpiration: Minutes? = nil,
            resetPasswordUrl: URL? = nil,
            resetPasswordExpiration: Minutes? = nil,
            resetPasswordTemplateId: String? = nil
        ) {
            self.email = email
            self.loginUrl = loginUrl
            self.loginExpiration = loginExpiration
            self.resetPasswordUrl = resetPasswordUrl
            self.resetPasswordExpiration = resetPasswordExpiration
            self.resetPasswordTemplateId = resetPasswordTemplateId
        }
    }

    /// The dedicated parameters type for passwords `resetByEmail` calls.
    struct ResetByEmailParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case token, password, sessionDuration = "sessionDurationMinutes" }

        public let token: String
        public let password: String
        public let sessionDuration: Minutes

        /// - Parameters:
        ///   - token: The reset token as parsed from the resulting reset deeplink. NOTE: - You must parse this manually.
        ///   - password: The user's updated password.
        ///   - sessionDuration: The duration of the requested session.
        public init(token: String, password: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.token = token
            self.password = password
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.Passwords {
    /// The dedicated parameters type for passwords `resetBySession` calls
    struct ResetBySessionParameters: Encodable {
        private enum CodingKeys: String, CodingKey { case password, sessionDuration = "sessionDurationMinutes" }

        public let password: String
        public let sessionDuration: Minutes

        /// - Parameters:
        ///   - password: The user's updated password.
        ///   - sessionDuration: The duration of the requested session.
        public init(password: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.password = password
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.Passwords {
    /// The dedicated parameters type for passwords `resetByExistingPassword` calls.
    struct ResetByExistingPasswordParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case email = "emailAddress"
            case existingPassword
            case newPassword
            case sessionDuration = "sessionDurationMinutes"
        }

        public let email: String
        public let existingPassword: String
        public let newPassword: String
        public let sessionDuration: Minutes

        /// - Parameters:
        ///   - email: The user's email address.
        ///   - existingPassword: The user's existing password.
        ///   - newPassword: The user's new password.
        ///   - sessionDuration: The duration of the requested session.
        public init(
            email: String,
            existingPassword: String,
            newPassword: String,
            sessionDuration: Minutes = .defaultSessionDuration
        ) {
            self.email = email
            self.existingPassword = existingPassword
            self.newPassword = newPassword
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.Passwords {
    /// The concrete response type for passwords `strengthCheck` calls.
    typealias StrengthCheckResponse = Response<StrengthCheckResponseData>

    /// The dedicated parameters type for passwords `strengthCheck` calls.
    struct StrengthCheckParameters: Encodable {
        let email: String?
        let password: String

        /// - Parameters:
        ///   - email: A user's email address.
        ///   - password: The password for the strength check.
        public init(email: String? = nil, password: String) {
            self.email = email
            self.password = password
        }
    }

    /// The underlying data for passwords `strengthCheck` calls.
    struct StrengthCheckResponseData: Codable {
        public let validPassword: Bool
        /// A score from 0-4 to indicate the strength of a password. Useful for progress bars.
        public let score: Double
        public let breachedPassword: Bool
        public let feedback: Feedback?

        /// A warning and collection of suggestions for improving the strength of a given password.
        public struct Feedback: Codable {
            public let suggestions: [String]
            public let warning: String
            public let ludsRequirements: LudsRequirement?
        }

        /// An explanation of how a given password passes or fails a LUDS check
        public struct LudsRequirement: Codable {
            public let hasLowerCase: Bool
            public let hasUpperCase: Bool
            public let hasDigit: Bool
            public let hasSymbol: Bool
            public let missingComplexity: Int
            public let missingCharacters: Int
        }
    }
}

#if DEBUG
extension StytchClient.Passwords.CreateResponseData: Encodable {}
#endif
