import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with passwords products.
    static var passwords: Passwords {
        .init(router: router.scopedRouter { $0.passwords })
    }
}

public extension StytchB2BClient {
    /// Stytch supports creating, storing, and authenticating passwords, as well as support for account recovery (password reset) and account deduplication with passwordless login methods.
    /// Our implementation of passwords has built-in breach detection powered by [HaveIBeenPwned](https://haveibeenpwned.com/) on both sign-up and login, to prevent the use of compromised credentials and uses configurable strength requirements (either Dropbox’s [zxcvbn](https://github.com/dropbox/zxcvbn) or adjustable LUDS) to guide members towards creating passwords that are easy for humans to remember but difficult for computers to crack.
    struct Passwords {
        let router: NetworkingRouter<PasswordsRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Authenticate a member with their email address and password. This method verifies that the member has a password currently set, and that the entered password is correct.
        ///
        /// There are two instances where the endpoint will return a reset_password error even if they enter their previous password:
        /// 1. The member's credentials appeared in the HaveIBeenPwned dataset.
        ///   a. We force a password reset to ensure that the member is the legitimate owner of the email address, and not a malicious actor abusing the compromised credentials.
        /// 2. The member used email based authentication (e.g. Magic Links, Google OAuth) for the first time, and had not previously verified their email address for password based login.
        ///   a. We force a password reset in this instance in order to safely deduplicate the account by email address, without introducing the risk of a pre-hijack account-takeover attack.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BMFAAuthenticateResponse {
            let mfaAuthenticateResponse: B2BMFAAuthenticateResponse = try await router.post(
                to: .authenticate,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                ),
                useDFPPA: true
            )

            sessionManager.b2bLastAuthMethodUsed = .passwords

            return mfaAuthenticateResponse
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
                ),
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Reset the member’s password and authenticate them. This endpoint checks that the magic link token is valid, hasn’t expired, or already been used.
        ///
        /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the member is authenticated.
        public func resetByEmail(parameters: ResetByEmailParameters) async throws -> B2BMFAAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                throw StytchSDKError.missingPKCE
            }

            let intermediateSessionTokenParameters = IntermediateSessionTokenParameters(
                intermediateSessionToken: sessionManager.intermediateSessionToken,
                wrapped: CodeVerifierParameters(
                    codeVerifier: pkcePair.codeVerifier,
                    wrapped: parameters
                )
            )

            let mfaAuthenticateResponse: B2BMFAAuthenticateResponse = try await router.post(
                to: .resetByEmail(.complete),
                parameters: intermediateSessionTokenParameters,
                useDFPPA: true
            )

            sessionManager.b2bLastAuthMethodUsed = .passwords

            return mfaAuthenticateResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Reset the member’s password and authenticate them. This endpoint checks that the existing password matches the stored value.
        ///
        /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the member is authenticated.
        public func resetByExistingPassword(parameters: ResetByExistingPasswordParameters) async throws -> B2BMFAAuthenticateResponse {
            let mfaAuthenticateResponse: B2BMFAAuthenticateResponse = try await router.post(
                to: .resetByExistingPassword,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                ),
                useDFPPA: true
            )

            sessionManager.b2bLastAuthMethodUsed = .passwords

            return mfaAuthenticateResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Reset the member’s password and authenticate them. This endpoint checks that the session is valid and hasn’t expired or been revoked.
        ///
        /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the member is authenticated.
        public func resetBySession(parameters: ResetBySessionParameters) async throws -> ResetBySessionResponse {
            try await router.post(to: .resetBySession, parameters: parameters, useDFPPA: true)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// This method allows you to check whether the member's provided password is valid, and to provide feedback to the member on how to increase the strength of their password.
        ///
        /// Passwords are considered invalid if one of the following is true:
        ///
        /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2 (if using zxcvbn).
        /// 1. The configured LUDS requirements have not been met.
        /// 2. The password is present in the HaveIBeenPwned dataset.
        ///
        /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password.
        /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors the feedback of the zxcvbn or LUDS analysis.
        public func strengthCheck(parameters: StrengthCheckParameters) async throws -> StrengthCheckResponse {
            try await router.post(to: .strengthCheck, parameters: parameters)
        }
    }
}

public extension StytchB2BClient.Passwords {
    /// The dedicated parameters type for password `authenticate` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let organizationId: Organization.ID
        let emailAddress: String
        let password: String
        let sessionDurationMinutes: Minutes
        let locale: StytchLocale

        ///  - Parameters:
        ///    - organizationId: The ID of the intended organization.
        ///    - emailAddress: The members's email address.
        ///    - password: The member's password.
        ///    - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        ///    - locale: Used to determine which language to use when sending the member this delivery method. Parameter is a IETF BCP 47 language tag, e.g. "en"
        public init(
            organizationId: Organization.ID,
            emailAddress: String,
            password: String,
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            locale: StytchLocale = .en
        ) {
            self.organizationId = organizationId
            self.emailAddress = emailAddress
            self.password = password
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.Passwords {
    /// The dedicated parameters type for passwords `resetByEmailStart` calls.
    struct ResetByEmailStartParameters: Encodable, Sendable {
        let organizationId: Organization.ID
        let emailAddress: String
        let loginRedirectUrl: URL?
        let resetPasswordRedirectUrl: URL?
        let resetPasswordExpirationMinutes: Minutes?
        let resetPasswordTemplateId: String?
        let verifyEmailTemplateId: String?
        let locale: StytchLocale

        /// - Parameters:
        ///   - organizationId: The ID of the intended organization.
        ///   - emailAddress: The member's email address.
        ///   - loginRedirectUrl: The url that the member clicks from the password reset email to skip resetting their password and directly login. This should be a url that your app receives, parses, and subsequently send an API request to complete the password reset process. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
        ///   - resetPasswordRedirectUrl: The url that the member clicks from the password reset email to finish the reset password flow. This should be a url that your app receives and parses and subsequently send an API request to authenticate the magic link and log in the member. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
        ///   - resetPasswordExpirationMinutes: Set the expiration for the password reset, in minutes. By default, it expires in 1 hour. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
        ///   - resetPasswordTemplateId: Use a custom template for password reset emails. If omitted, your default email template will be used. The template must be a template using our built-in customizations or a custom HTML email for Passwords - Password reset.
        ///   - verifyEmailTemplateId: Use a custom template for password verify emails. By default, it will use your default email template.
        ///     The template must be a template using our built-in customizations or a custom HTML email for Password Verification.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            organizationId: Organization.ID,
            emailAddress: String,
            loginRedirectUrl: URL? = nil,
            resetPasswordRedirectUrl: URL? = nil,
            resetPasswordExpirationMinutes: Minutes? = nil,
            resetPasswordTemplateId: String? = nil,
            verifyEmailTemplateId: String? = nil,
            locale: StytchLocale = .en
        ) {
            self.organizationId = organizationId
            self.emailAddress = emailAddress
            self.loginRedirectUrl = loginRedirectUrl
            self.resetPasswordRedirectUrl = resetPasswordRedirectUrl
            self.resetPasswordExpirationMinutes = resetPasswordExpirationMinutes
            self.resetPasswordTemplateId = resetPasswordTemplateId
            self.verifyEmailTemplateId = verifyEmailTemplateId
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.Passwords {
    /// The dedicated parameters type for passwords `resetByEmail` calls.
    struct ResetByEmailParameters: Encodable, Sendable {
        let passwordResetToken: String
        let password: String
        let sessionDurationMinutes: Minutes
        let locale: StytchLocale

        /// - Parameters:
        ///   - passwordResetToken: The reset token as parsed from the resulting reset deeplink. NOTE: - You must parse this manually.
        ///   - password: The members's updated password.
        ///   - sessionDurationMinutes: The duration of the requested session.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            passwordResetToken: String,
            password: String,
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            locale: StytchLocale = .en
        ) {
            self.passwordResetToken = passwordResetToken
            self.password = password
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.Passwords {
    /// The dedicated parameters type for passwords `resetByExistingPassword` calls.
    struct ResetByExistingPasswordParameters: Encodable, Sendable {
        let organizationId: Organization.ID
        let emailAddress: String
        let existingPassword: String
        let newPassword: String
        let sessionDurationMinutes: Minutes
        let locale: StytchLocale

        /// - Parameters:
        ///   - organizationId: The ID of the intended organization.
        ///   - emailAddress: The members's email address.
        ///   - existingPassword: The members's existing password.
        ///   - newPassword: The members's new password.
        ///   - sessionDurationMinutes: The duration of the requested session.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            organizationId: Organization.ID,
            emailAddress: String,
            existingPassword: String,
            newPassword: String,
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            locale: StytchLocale = .en
        ) {
            self.organizationId = organizationId
            self.emailAddress = emailAddress
            self.existingPassword = existingPassword
            self.newPassword = newPassword
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.Passwords {
    /// The concrete response type for passwords `resetBySession` calls.
    typealias ResetBySessionResponse = Response<ResetBySessionResponseData>

    /// The underlying data for passwords `resetBySession` calls.
    struct ResetBySessionResponseData: Codable, Sendable {
        /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let memberSession: MemberSession
        /// The current member object.
        public let member: Member
        /// The current organization object.
        public let organization: Organization
    }

    /// The dedicated parameters type for passwords `resetBySession` calls.
    struct ResetBySessionParameters: Encodable, Sendable {
        let organizationId: Organization.ID
        let password: String
        let locale: StytchLocale

        /// - Parameters:
        ///   - organizationId: The ID of the intended organization.
        ///   - password: The members's new password.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(organizationId: Organization.ID, password: String, locale: StytchLocale = .en) {
            self.organizationId = organizationId
            self.password = password
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.Passwords {
    /// The concrete response type for passwords `strengthCheck` calls.
    typealias StrengthCheckResponse = Response<StrengthCheckResponseData>

    /// The dedicated parameters type for passwords `strengthCheck` calls.
    struct StrengthCheckParameters: Encodable, Sendable {
        let emailAddress: String?
        let password: String

        /// - Parameters:
        ///   - emailAddress: A member's email address.
        ///   - password: The password for the strength check.
        public init(emailAddress: String? = nil, password: String) {
            self.emailAddress = emailAddress
            self.password = password
        }
    }

    /// The underlying data for passwords `strengthCheck` calls.
    struct StrengthCheckResponseData: Codable, Sendable {
        public let validPassword: Bool
        /// A score from 0-4 to indicate the strength of a password. Useful for progress bars.
        public let score: Double
        /// Returns true if the password has been breached. Powered by HaveIBeenPwned (https://haveibeenpwned.com).
        public let breachedPassword: Bool
        /// The strength policy type enforced, either zxcvbn or luds.
        public let strengthPolicy: StytchB2BClient.PasswordStrengthPolicy
        /// Will return true if breach detection will be evaluated. By default this option is enabled. This option can be disabled by contacting support@stytch.com. If this value is false then breached_password will always be false as well.
        public let breachDetectionOnCreate: Bool
        /// Feedback for how to improve the password's strength using zxcvbn.
        public let zxcvbnFeedback: ZxcvbnFeedback?
        /// Feedback for how to improve the password's strength using luds.
        public let ludsFeedback: LudsRequirement?

        /// A warning and collection of suggestions for improving the strength of a given password.
        public struct ZxcvbnFeedback: Codable, Sendable {
            /// For zxcvbn validation, contains end user consumable suggestions on how to improve the strength of the password.
            public let suggestions: [String]
            /// For zxcvbn validation, contains an end user consumable warning if the password is valid but not strong enough.
            public let warning: String
        }
    }
}
