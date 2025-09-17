import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with totp products.
    static var totp: TOTP {
        .init(router: router.scopedRouter {
            $0.totp
        })
    }
}

public extension StytchB2BClient {
    struct TOTP {
        let router: NetworkingRouter<StytchB2BClient.TOTPRoute>

        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants
        /// Create a TOTP for a member
        public func create(parameters: CreateParameters) async throws -> CreateResponse {
            try await router.post(
                to: .create,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants
        /// Authenticate a TOTP for a member
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

public extension StytchB2BClient.TOTP {
    struct CreateParameters: Codable, Sendable {
        let organizationId: String
        let memberId: String
        let expirationMinutes: Minutes

        /// - Parameters:
        ///   - organizationId: The ID of the organization the member belongs to
        ///   - memberId: The ID of the member creating a TOTP
        ///   - expirationMinutes: The expiration for the TOTP instance.
        ///   If the newly created TOTP is not authenticated within this time frame the TOTP will be unusable.
        ///   Defaults to 60 (1 hour) with a minimum of 5 and a maximum of 1440.
        public init(organizationId: String, memberId: String, expirationMinutes: Minutes) {
            self.organizationId = organizationId
            self.memberId = memberId
            self.expirationMinutes = expirationMinutes
        }
    }
}

public extension StytchB2BClient.TOTP {
    typealias CreateResponse = Response<CreateResponseData>

    struct CreateResponseData: Codable, Sendable {
        /// Globally unique UUID that identifies a specific TOTP registration in the Stytch API.
        public let totpRegistrationId: String

        /// The TOTP secret key shared between the authenticator app and the server used to generate TOTP codes.
        public let secret: String

        /// The QR code image encoded in base64.
        public let qrCode: String

        /// The recovery codes used to authenticate the member without an authenticator app.
        public let recoveryCodes: [String]
    }
}

public extension StytchB2BClient.TOTP {
    struct AuthenticateParameters: Codable, Sendable {
        let sessionDurationMinutes: Minutes
        let organizationId: String
        let memberId: String
        let code: String
        let setMfaEnrollment: StytchB2BClient.MFAEnrollment?
        let setDefaultMfa: Bool?

        /// - Parameters:
        ///   - sessionDurationMinutes: Set the session lifetime to be this many minutes from now.
        ///     This will return both an opaque `session_token` and `session_jwt` for this session, which will automatically be stored in the browser cookies.
        ///     The `session_jwt` will have a fixed lifetime of five minutes regardless of the underlying session duration, and will be automatically refreshed by the SDK in the background over time.
        ///     This value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the https://stytch.com/dashboard/sdk-configuration SDK Configuration page of the Stytch dashboard.
        ///   - organizationId: The ID of the organization the member belongs to
        ///   - memberId: The ID of the member to authenticate
        ///   - code: The TOTP code to authenticate
        ///   - setMfaEnrollment: If set to 'enroll', enrolls the member in MFA by setting the "mfa_enrolled" boolean to true.
        ///     If set to 'unenroll', unenrolls the member in MFA by setting the "mfa_enrolled" boolean to false.
        ///     If not set, does not affect the member's MFA enrollment.
        ///   - setDefaultMfa: If set to true, sets TOTP as the member's default MFA method.
        public init(
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            organizationId: String,
            memberId: String,
            code: String,
            setMfaEnrollment: StytchB2BClient.MFAEnrollment? = nil,
            setDefaultMfa: Bool? = nil
        ) {
            self.sessionDurationMinutes = sessionDurationMinutes
            self.organizationId = organizationId
            self.memberId = memberId
            self.code = code
            self.setMfaEnrollment = setMfaEnrollment
            self.setDefaultMfa = setDefaultMfa
        }
    }
}
