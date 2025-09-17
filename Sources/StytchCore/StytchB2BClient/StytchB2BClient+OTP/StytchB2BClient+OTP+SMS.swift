import Foundation

public extension StytchB2BClient.OTP {
    /// The interface for interacting with otp sms products.
    var sms: SMS {
        .init(router: router.scopedRouter {
            $0.sms
        })
    }
}

public extension StytchB2BClient.OTP {
    struct SMS {
        let router: NetworkingRouter<StytchB2BClient.OTPRoute.SMSRoute>

        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants
        /// Send a one-time passcode (OTP) to a user using their phone number via SMS.
        public func send(parameters: SendParameters) async throws -> BasicResponse {
            try await router.post(
                to: .send,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants
        /// Authenticate a one-time passcode (OTP) sent to a user via SMS.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BAuthenticateResponse {
            try await router.post(
                to: .authenticate,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }
    }
}

public extension StytchB2BClient.OTP.SMS {
    struct SendParameters: Codable, Sendable {
        let organizationId: String
        let memberId: String
        let mfaPhoneNumber: String?
        let locale: StytchLocale
        let enableAutofill: Bool

        /// - Parameters:
        ///   - organizationId: The ID of the organization the member belongs to
        ///   - memberId: The ID of the member to send the OTP to
        ///   - mfaPhoneNumber: The phone number to send the OTP to. If the member already has a phone number, this argument is not needed.
        ///     If the member does not have a phone number and this argument is not provided, an error will be thrown.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        ///   - enableAutofill: indicates whether the SMS message should include autofill metadata
        public init(organizationId: String, memberId: String, mfaPhoneNumber: String? = nil, locale: StytchLocale = .en, enableAutofill: Bool = false) {
            self.organizationId = organizationId
            self.memberId = memberId
            self.mfaPhoneNumber = mfaPhoneNumber
            self.locale = locale
            self.enableAutofill = enableAutofill
        }
    }
}

public extension StytchB2BClient.OTP.SMS {
    struct AuthenticateParameters: Codable, Sendable {
        let sessionDurationMinutes: Minutes
        let organizationId: String
        let memberId: String
        let code: String
        let setMfaEnrollment: StytchB2BClient.MFAEnrollment?

        /// - Parameters:
        ///   - sessionDurationMinutes: Set the session lifetime to be this many minutes from now.
        ///     This will return both an opaque `session_token` and `session_jwt` for this session, which will automatically be stored in the browser cookies.
        ///     The `session_jwt` will have a fixed lifetime of five minutes regardless of the underlying session duration, and will be automatically refreshed by the SDK in the background over time.
        ///     This value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the https://stytch.com/dashboard/sdk-configuration SDK Configuration page of the Stytch dashboard.
        ///   - organizationId: The ID of the organization the member belongs to
        ///   - memberId: The ID of the member to authenticate
        ///   - code: The OTP code to authenticate
        ///   - setMfaEnrollment: If set to 'enroll', enrolls the member in MFA by setting the "mfa_enrolled" boolean to true.
        ///     If set to 'unenroll', unenrolls the member in MFA by setting the "mfa_enrolled" boolean to false.
        ///     If not set, does not affect the member's MFA enrollment.
        public init(
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            organizationId: String,
            memberId: String,
            code: String,
            setMfaEnrollment: StytchB2BClient.MFAEnrollment? = nil
        ) {
            self.sessionDurationMinutes = sessionDurationMinutes
            self.organizationId = organizationId
            self.memberId = memberId
            self.code = code
            self.setMfaEnrollment = setMfaEnrollment
        }
    }
}
