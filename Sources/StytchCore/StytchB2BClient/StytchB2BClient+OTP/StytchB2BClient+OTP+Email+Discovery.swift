import Foundation

public extension StytchB2BClient.OTP.Email {
    /// The interface for interacting with otp email discovery products.
    var discovery: Discovery {
        .init(router: router.scopedRouter {
            $0.discovery
        })
    }
}

public extension StytchB2BClient.OTP.Email {
    struct Discovery {
        let router: NetworkingRouter<StytchB2BClient.OTPRoute.EmailRoute.DiscoveryRoute>

        // sourcery: AsyncVariants
        /// Send a one-time passcode (OTP) to a user using their email address.
        public func send(parameters: SendParameters) async throws -> BasicResponse {
            try await router.post(to: .send, parameters: parameters, useDFPPA: true)
        }

        // sourcery: AsyncVariants
        /// Authenticate a one-time passcode (OTP) sent to a user via email.
        public func authenticate(parameters: AuthenticateParameters) async throws -> StytchB2BClient.DiscoveryAuthenticateResponse {
            try await router.post(to: .authenticate, parameters: parameters, useDFPPA: true)
        }
    }
}

public extension StytchB2BClient.OTP.Email.Discovery {
    struct SendParameters: Codable, Sendable {
        /// The email address to send the OTP to.
        let emailAddress: String
        /// The email template ID to use for login emails. If not provided, your default email template will be sent.
        /// If providing a template ID, it must be either a template using Stytch's customizations, or an OTP Login custom HTML template.
        let loginTemplateId: String?
        /// The locale is used to determine which language to use in the email. Parameter is a {@link https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag}, e.g. "en".
        /// Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        let locale: StytchLocale?

        public init(
            emailAddress: String,
            loginTemplateId: String? = nil,
            locale: StytchLocale? = nil
        ) {
            self.emailAddress = emailAddress
            self.loginTemplateId = loginTemplateId
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.OTP.Email.Discovery {
    struct AuthenticateParameters: Codable, Sendable {
        /// The OTP to authenticate the user.
        let code: String
        /// The email address of the member attempting to authenticate.
        let emailAddress: String

        public init(
            code: String,
            emailAddress: String
        ) {
            self.code = code
            self.emailAddress = emailAddress
        }
    }
}
