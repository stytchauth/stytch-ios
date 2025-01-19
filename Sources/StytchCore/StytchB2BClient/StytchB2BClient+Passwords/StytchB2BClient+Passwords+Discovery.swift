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

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        ///
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
        ///
        public func resetByEmail(parameters: ResetByEmailParameters) async throws -> StytchB2BClient.DiscoveryAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                throw StytchSDKError.missingPKCE
            }

            return try await router.post(
                to: .resetByEmail,
                parameters: CodeVerifierParameters(
                    codingPrefix: .pkce,
                    codeVerifier: pkcePair.codeVerifier,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        ///
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
        let resetPasswordExpirationMinutes: Int?
        let resetPasswordTemplateId: String?

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

        public init(
            emailAddress: String,
            discoveryRedirectUrl: URL? = nil,
            resetPasswordRedirectUrl: URL? = nil,
            resetPasswordExpirationMinutes: Int? = nil,
            resetPasswordTemplateId: String? = nil
        ) {
            self.emailAddress = emailAddress
            self.discoveryRedirectUrl = discoveryRedirectUrl
            self.resetPasswordRedirectUrl = resetPasswordRedirectUrl
            self.resetPasswordExpirationMinutes = resetPasswordExpirationMinutes
            self.resetPasswordTemplateId = resetPasswordTemplateId
        }
    }

    struct ResetByEmailParameters: Encodable, Sendable {
        let passwordResetToken: String
        let password: String

        /// - Parameters:
        ///   - passwordResetToken: The token to authenticate.
        ///   - password: The new password for the Member.
        public init(passwordResetToken: String, password: String) {
            self.passwordResetToken = passwordResetToken
            self.password = password
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
