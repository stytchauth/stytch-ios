@preconcurrency import SwiftyJSON

public extension StytchClient {
    /// Time-based One-time Passcodes (TOTPs) are one-time passcodes that are generated based on a shared secret and the current time. TOTPs are also often referred to as Authenticator Apps and are a common form of secondary authentication. Creating a Stytch instance of a TOTP for a User creates a shared secret. This secret is shared by Stytch with the end user's authenticator application of choice (e.g. Google Authenticator). The authenticator app can then generate TOTPs that are valid for a specific amount of time (generally 30 seconds). The end user inputs the TOTP and the developer can use the authenticate method to verify that the TOTP is valid. To call these methods, TOTPs must be enabled in the [SDK Configuration page](https://stytch.com/dashboard/sdk-configuration) of the Stytch dashboard.
    struct TOTP {
        let router: NetworkingRouter<TOTPRoute>
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [create](https://stytch.com/docs/api/totp-create) endpoint. Call this method to create a new TOTP instance for a user. The user can use the authenticator application of their choice to scan the QR code or enter the secret.
        public func create(parameters: CreateParameters) async throws -> CreateResponse {
            try await router.post(to: .create, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/totp-authenticate) endpoint. Call this method to authenticate a TOTP code entered by a user.
        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
            let authenticateResponse: AuthenticateResponse = try await router.post(to: .authenticate, parameters: parameters, useDFPPA: true)
            sessionManager.consumerLastAuthMethodUsed = .totp
            return authenticateResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [recovery_codes](https://stytch.com/docs/api/totp-get-recovery-codes) endpoint. Call this method to retrieve the recovery codes for a TOTP instance tied to a user. Note: If a user has enrolled another MFA method, this method will require MFA. See the [Multi-factor authentication](https://stytch.com/docs/sdks/javascript-sdk#resources_multi-factor-authentication) section for more details.
        public func recoveryCodes() async throws -> RecoveryCodesResponse {
            try await router.post(to: .recoveryCodes, parameters: JSON())
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's [recover](https://stytch.com/docs/api/totp-recover) endpoint. Call this method to authenticate a recovery code for a TOTP instance.
        public func recover(parameters: RecoverParameters) async throws -> RecoverResponse {
            try await router.post(to: .recover, parameters: parameters, useDFPPA: true)
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with TOTP products.
    static var totps: TOTP { .init(router: router.scopedRouter { $0.totp }) }
}

public extension StytchClient.TOTP {
    /// A dedicated parameters type for TOTP ``StytchClient/TOTP/create(parameters:)-437r4`` calls.
    struct CreateParameters: Encodable, Sendable {
        let expirationMinutes: Minutes

        /// - Parameter expirationMinutes: The expiration for the TOTP instance. If the newly created TOTP is not authenticated within this time frame the TOTP will be unusable. Defaults to 60 (1 hour) with a minimum of 5 and a maximum of 1440.
        public init(expirationMinutes: Minutes = StytchClient.defaultSessionDuration) {
            self.expirationMinutes = expirationMinutes
        }
    }

    /// A dedicated parameters type for TOTP ``StytchClient/TOTP/authenticate(parameters:)-2ck6w`` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let totpCode: String
        let sessionDurationMinutes: Minutes

        /// - Parameters:
        ///   - totpCode: The TOTP code to authenticate. The TOTP code should consist of 6 digits.
        ///   - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        public init(totpCode: String, sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration) {
            self.totpCode = totpCode
            self.sessionDurationMinutes = sessionDurationMinutes
        }
    }

    /// A dedicated parameters type for TOTP ``StytchClient/TOTP/recover(parameters:)-9swfk`` calls.
    struct RecoverParameters: Encodable, Sendable {
        let recoveryCode: String
        let sessionDurationMinutes: Minutes

        /// - Parameters:
        ///   - recoveryCode: The recovery code to authenticate.
        ///   - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
        public init(recoveryCode: String, sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration) {
            self.recoveryCode = recoveryCode
            self.sessionDurationMinutes = sessionDurationMinutes
        }
    }
}

public extension StytchClient.TOTP {
    /// The concrete response type for TOTP ``StytchClient/TOTP/create(parameters:)-437r4`` calls.
    typealias CreateResponse = Response<CreateResponseData>
    /// The concrete response type for TOTP ``StytchClient/TOTP/recover(parameters:)-9swfk`` calls.
    typealias RecoverResponse = Response<RecoverResponseData>
    /// The concrete response type for TOTP ``StytchClient/TOTP/recoveryCodes()-mbxc`` calls.
    typealias RecoveryCodesResponse = Response<RecoveryCodesResponseData>

    /// The underlying data for TOTP ``StytchClient/TOTP/create(parameters:)-437r4`` responses.
    struct CreateResponseData: Codable, Sendable {
        public let totpId: User.TOTP.ID
        public let secret: String
        public let qrCode: String
        public let recoveryCodes: [String]
        public let user: User
        public let userId: User.ID
    }

    /// The underlying data for TOTP ``StytchClient/TOTP/recover(parameters:)-9swfk`` responses.
    struct RecoverResponseData: Codable, Sendable, AuthenticateResponseDataType {
        public let userId: User.ID
        public let totpId: User.TOTP.ID
        public let user: User
        public let session: Session
        public let sessionToken: String
        public let sessionJwt: String
        public let userDevice: DeviceHistory?
    }

    /// The underlying data for TOTP ``StytchClient/TOTP/recoveryCodes()-mbxc`` responses.
    struct RecoveryCodesResponseData: Codable, Sendable {
        public let userId: User.ID
        public let totps: [Union<User.TOTP, RecoveryCodes>]
    }

    /// Additional data unioned to the ``User`` type.
    struct RecoveryCodes: Codable, Sendable {
        public let recoveryCodes: [String]
    }
}
