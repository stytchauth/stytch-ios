import Foundation

public extension StytchB2BClient.Passwords {
    /// The interface for interacting with otp email discovery products.
    var discovery: Discovery {
        .init(router: router.scopedRouter {
            $0.discovery
        })
    }
}

public extension StytchB2BClient.Passwords {
    struct Discovery {
        let router: NetworkingRouter<StytchB2BClient.PasswordsRoute.DiscoveryRoute>

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Initiates a password reset for the email address provided, when cross-org passwords are enabled.
        /// This will trigger an email to be sent to the address, containing a magic link that will allow them to set a new password and authenticate.
        public func resetByEmailStart(parameters: ResetByEmailStartParameters) async throws -> BasicResponse {
            let pkcePair = try pkcePairManager.generateAndReturnPKCECodePair()
            return try await router.post(
                to: .resetByEmailStart,
                parameters: CodeChallengedParameters(
                    codingPrefix: .pkce,
                    codeChallenge: pkcePair.codeChallenge,
                    codeChallengeMethod: pkcePair.method,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Reset the password associated with an email and start an intermediate session.
        /// This endpoint checks that the password reset token is valid, hasn’t expired, or already been used.
        public func resetByEmail(parameters: ResetByEmailParameters) async throws -> StytchB2BClient.DiscoveryAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                throw StytchSDKError.missingPKCE
            }

            let intermediateSessionTokenParameters = IntermediateSessionTokenParameters(
                intermediateSessionToken: sessionManager.intermediateSessionToken,
                wrapped: CodeVerifierParameters(
                    codingPrefix: .pkce,
                    codeVerifier: pkcePair.codeVerifier,
                    wrapped: parameters
                )
            )

            return try await router.post(
                to: .resetByEmail,
                parameters: intermediateSessionTokenParameters,
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Authenticate an email/password combination in the discovery flow.
        /// This authenticate flow is only valid for cross-org passwords use cases, and is not tied to a specific organization.
        public func authenticate(parameters: AuthenticateParameters) async throws -> StytchB2BClient.DiscoveryAuthenticateResponse {
            try await router.post(
                to: .authenticate,
                parameters: parameters,
                useDFPPA: true
            )
        }
    }
}

public extension StytchB2BClient.Passwords.Discovery {
    struct ResetByEmailStartParameters: Encodable, Sendable {
        let emailAddress: String
        let discoveryRedirectUrl: URL?
        let resetPasswordRedirectUrl: URL?
        let resetPasswordExpirationMinutes: Minutes?
        let resetPasswordTemplateId: String?
        let verifyEmailTemplateId: String?
        let locale: StytchLocale

        /// - Parameters:
        ///   - emailAddress: The email that requested the password reset.
        ///   - discoveryRedirectUrl: The URL that the Member clicks from the password reset email to skip resetting their
        ///     password and directly log in. This should be a URL that your app receives, parses, and subsequently sends an API
        ///     request to the magic link authenticate endpoint to complete the login process without resetting their password.
        ///     If this value is not passed, the login redirect URL that you set in your Dashboard is used. If you have not set
        ///     a default login redirect URL, an error is returned.
        ///   - resetPasswordRedirectUrl: The URL that the Member clicks from the password reset email to finish the reset password
        ///     flow. This should be a URL that your app receives and parses before showing your app's reset password page. After
        ///     the Member submits a new password to your app, it should send an API request to complete the password reset process.
        ///     If this value is not passed, the default reset password redirect URL that you set in your Dashboard is used. If you
        ///     have not set a default reset password redirect URL, an error is returned.
        ///   - resetPasswordExpirationMinutes: Set the expiration for the password reset, in minutes. By default, it expires in
        ///     30 minutes. The minimum expiration is 5 minutes, and the maximum is 7 days (10080 minutes).
        ///   - resetPasswordTemplateId: The email template ID to use for password reset. If not provided, your default email
        ///     template will be sent. If providing a template ID, it must be either a template using Stytch's customizations or a
        ///     Passwords reset custom HTML template.
        ///   - verifyEmailTemplateId: Use a custom template for password verify emails. By default, it will use your default email template.
        ///     The template must be a template using our built-in customizations or a custom HTML email for Password Verification.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            emailAddress: String,
            discoveryRedirectUrl: URL? = nil,
            resetPasswordRedirectUrl: URL? = nil,
            resetPasswordExpirationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            resetPasswordTemplateId: String? = nil,
            verifyEmailTemplateId: String? = nil,
            locale: StytchLocale = .en
        ) {
            self.emailAddress = emailAddress
            self.discoveryRedirectUrl = discoveryRedirectUrl
            self.resetPasswordRedirectUrl = resetPasswordRedirectUrl
            self.resetPasswordExpirationMinutes = resetPasswordExpirationMinutes
            self.resetPasswordTemplateId = resetPasswordTemplateId
            self.verifyEmailTemplateId = verifyEmailTemplateId
            self.locale = locale
        }
    }

    struct ResetByEmailParameters: Encodable, Sendable {
        let passwordResetToken: String
        let password: String
        let locale: StytchLocale

        /// - Parameters:
        ///   - passwordResetToken: The token to authenticate.
        ///   - password: The new password for the Member.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            passwordResetToken: String,
            password: String,
            locale: StytchLocale = .en
        ) {
            self.passwordResetToken = passwordResetToken
            self.password = password
            self.locale = locale
        }
    }

    struct AuthenticateParameters: Encodable, Sendable {
        let emailAddress: String
        let password: String

        /// - Parameters:
        ///   - emailAddress: The email attempting to login.
        ///   - password: The password for the email address.
        public init(emailAddress: String, password: String) {
            self.emailAddress = emailAddress
            self.password = password
        }
    }
}

public extension StytchB2BClient.Passwords.Discovery {}
