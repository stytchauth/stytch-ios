import Foundation

public extension StytchB2BClient.OTP {
    /// The interface for interacting with otp email products.
    var email: Email {
        .init(router: router.scopedRouter {
            $0.email
        })
    }
}

public extension StytchB2BClient.OTP {
    struct Email {
        let router: NetworkingRouter<StytchB2BClient.OTPRoute.EmailRoute>
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants
        /// Send a one-time passcode (OTP) to a user using email address.
        public func loginOrSignup(parameters: LoginOrSignupParameters) async throws -> BasicResponse {
            try await router.post(to: .loginOrSignup, parameters: parameters, useDFPPA: true)
        }

        // sourcery: AsyncVariants
        /// Authenticate a one-time passcode (OTP) sent to a user via Email.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            let authenticateResponse: AuthenticateResponse = try await router.post(to: .authenticate, parameters: parameters, useDFPPA: true)
            sessionManager.b2bLastAuthMethodUsed = .emailOtp
            return authenticateResponse
        }
    }
}

public extension StytchB2BClient.OTP.Email {
    struct LoginOrSignupParameters: Codable, Sendable {
        /// The ID of the organization the member belongs to.
        let organizationId: String
        /// The email of the member to send the OTP to.
        let emailAddress: String
        /// The email template ID to use for login emails. If not provided, your default email template will be sent.
        /// If providing a template ID, it must be either a template using Stytch's customizations, or an OTP Login custom HTML template.
        let loginTemplateId: String?
        /// The email template ID to use for sign-up emails.
        /// If not provided, your default email template will be sent. If providing a template ID, it must be either a template using Stytch's customizations,
        /// or an OTP Sign-up custom HTML template.
        let signupTemplateId: String?
        /// The locale is used to determine which language to use in the email. Parameter is a {@link https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag}, e.g. "en".
        /// Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        let locale: StytchLocale

        public init(
            organizationId: String,
            emailAddress: String,
            loginTemplateId: String? = nil,
            signupTemplateId: String? = nil,
            locale: StytchLocale = .en
        ) {
            self.organizationId = organizationId
            self.emailAddress = emailAddress
            self.loginTemplateId = loginTemplateId
            self.signupTemplateId = signupTemplateId
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.OTP.Email {
    /// The concrete response type for B2B OTP Email `authenticate` calls.
    typealias AuthenticateResponse = Response<AuthenticateResponseData>

    struct AuthenticateResponseData: Codable, Sendable, B2BMFAAuthenticateResponseDataType {
        /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let memberSession: MemberSession?
        /// The current member's ID.
        public let memberId: Member.ID
        /// The current member object.
        public let member: Member
        /// The current organization object.
        public let organization: Organization
        /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
        public let sessionToken: String
        /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
        public let sessionJwt: String
        /// An optional intermediate session token to be returned if multi factor authentication is enabled
        public let intermediateSessionToken: String?
        /// Indicates whether the Member is fully authenticated. If false, the Member needs to complete an MFA step to log in to the Organization.
        public let memberAuthenticated: Bool
        /// Information about the MFA requirements of the Organization and the Member's options for fulfilling MFA.
        public let mfaRequired: StytchB2BClient.MFARequired?
        /// Information about the primary authentication requirements of the Organization.
        public let primaryRequired: StytchB2BClient.PrimaryRequired?
        /// If a valid telemetry_id was passed in the request and the Fingerprint Lookup API returned results, the member_device response field will contain information about the member's device attributes.
        public let memberDevice: DeviceHistory?
        /// The ID of the email used to send an OTP.
        public let methodId: String
    }

    struct AuthenticateParameters: Codable, Sendable {
        /// The OTP to authenticate
        let code: String
        /// The organization ID of the member attempting to authenticate for.
        let organizationId: String
        /// The email of the member we're attempting to authenticate the otp for.
        let emailAddress: String
        /// The locale will be used if an OTP code is sent to the member's phone number as part of a secondary authentication requirement.
        let locale: StytchLocale
        /// This will return both an opaque `session_token` and `session_jwt` for this session, which will automatically be stored in the browser cookies.
        /// The `session_jwt` will have a fixed lifetime of five minutes regardless of the underlying session duration, and will be automatically refreshed by the SDK in the background over time.
        /// This value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the https://stytch.com/dashboard/sdk-configuration SDK Configuration page of the Stytch dashboard.
        let sessionDurationMinutes: Minutes

        public init(
            code: String,
            organizationId: String,
            emailAddress: String,
            locale: StytchLocale = .en,
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration
        ) {
            self.code = code
            self.organizationId = organizationId
            self.emailAddress = emailAddress
            self.locale = locale
            self.sessionDurationMinutes = sessionDurationMinutes
        }
    }
}
