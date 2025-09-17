import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with otp products.
    static var recoveryCodes: RecoveryCodes {
        .init(router: router.scopedRouter {
            $0.recoveryCodes
        })
    }
}

public extension StytchB2BClient {
    struct RecoveryCodes {
        let router: NetworkingRouter<StytchB2BClient.RecoveryCodesRoute>

        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants
        /// Get the recovery codes for an authenticated member
        public func get() async throws -> RecoveryCodesResponse {
            try await router.get(route: .get)
        }

        // sourcery: AsyncVariants
        /// Rotate the recovery codes for an authenticated member
        public func rotate() async throws -> RecoveryCodesResponse {
            try await router.post(to: .rotate, useDFPPA: true)
        }

        // sourcery: AsyncVariants
        /// Consume a recovery code for a member
        public func recover(parameters: RecoveryCodesRecoverParameters) async throws -> RecoveryCodesRecoverResponse {
            try await router.post(
                to: .recover,
                parameters: IntermediateSessionTokenParameters(
                    intermediateSessionToken: sessionManager.intermediateSessionToken,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }
    }
}

public extension StytchB2BClient.RecoveryCodes {
    typealias RecoveryCodesResponse = Response<RecoveryCodesResponseData>

    struct RecoveryCodesResponseData: Codable, Sendable {
        /// The recovery codes used to authenticate the member in place of a secondary factor.
        public let recoveryCodes: [String]
    }
}

public extension StytchB2BClient.RecoveryCodes {
    struct RecoveryCodesRecoverParameters: Codable, Sendable {
        let sessionDurationMinutes: Minutes
        let organizationId: String
        let memberId: String
        let recoveryCode: String

        /// - Parameters:
        ///   - sessionDurationMinutes: Set the session lifetime to be this many minutes from now.
        ///     This will return both an opaque `session_token` and `session_jwt` for this session, which will automatically be stored in the browser cookies.
        ///     The `session_jwt` will have a fixed lifetime of five minutes regardless of the underlying session duration, and will be automatically refreshed by the SDK in the background over time.
        ///     This value must be a minimum of 5 and may not exceed the maximum session duration minutes value set in the https://stytch.com/dashboard/sdk-configuration SDK Configuration page of the Stytch dashboard.
        ///   - organizationId: The ID of the organization the member belongs to
        ///   - memberId: The ID of the member creating a TOTP
        ///   - recoveryCode: The recovery code to authenticate.
        public init(
            sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration,
            organizationId: String,
            memberId: String,
            recoveryCode: String
        ) {
            self.sessionDurationMinutes = sessionDurationMinutes
            self.organizationId = organizationId
            self.memberId = memberId
            self.recoveryCode = recoveryCode
        }
    }
}

public extension StytchB2BClient.RecoveryCodes {
    typealias RecoveryCodesRecoverResponse = Response<RecoveryCodesRecoverResponseData>

    struct RecoveryCodesRecoverResponseData: B2BAuthenticateResponseDataType, Codable, Sendable {
        /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
        public let memberSession: MemberSession
        /// The current member object.
        public let member: Member
        /// The current organization object.
        public let organization: Organization
        /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
        public let sessionToken: String
        /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
        public let sessionJwt: String
        /// If a valid telemetry_id was passed in the request and the Fingerprint Lookup API returned results, the member_device response field will contain information about the member's device attributes.
        public let memberDevice: DeviceHistory?
        /// Number of recovery codes remaining for the member.
        public let recoveryCodesRemaining: Int
    }
}
