public extension StytchClient {
    struct TOTP {
        let router: NetworkingRouter<TOTPRoute>

        public func create(parameters: CreateParameters) async throws -> CreateResponse {
            try await router.post(to: .create, parameters: parameters)
        }

        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponseType {
            try await router.post(to: .authenticate, parameters: parameters) as AuthenticateResponse
        }

        public func recoveryCodes() async throws -> RecoveryCodesResponse {
            try await router.post(to: .recoveryCodes, parameters: JSON())
        }

        public func recover(parameters: RecoverParameters) async throws -> RecoverResponse {
            try await router.post(to: .recover, parameters: parameters)
        }
    }
}

public extension StytchClient {
    static var totp: TOTP { .init(router: router.scopedRouter(BaseRoute.totp)) }
}

public extension StytchClient.TOTP {
    struct CreateParameters: Encodable {
        enum CodingKeys: String, CodingKey {
            case expiration = "expiration_minutes"
        }

        let expiration: Minutes

        public init(expiration: Minutes = .defaultSessionDuration) {
            self.expiration = expiration
        }
    }

    struct AuthenticateParameters: Encodable {
        enum CodingKeys: String, CodingKey {
            case totpCode
            case sessionDuration = "session_duration_minutes"
        }

        let totpCode: String
        let sessionDuration: Minutes

        public init(totpCode: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.totpCode = totpCode
            self.sessionDuration = sessionDuration
        }
    }

    struct RecoverParameters: Encodable {
        enum CodingKeys: String, CodingKey {
            case recoveryCode
            case sessionDuration = "session_duration_minutes"
        }

        let recoveryCode: String
        let sessionDuration: Minutes

        public init(recoveryCode: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.recoveryCode = recoveryCode
            self.sessionDuration = sessionDuration
        }
    }
}

public extension StytchClient.TOTP {
    typealias CreateResponse = Response<CreateResponseData>
    typealias RecoverResponse = Response<RecoverResponseData>
    typealias RecoveryCodesResponse = Response<RecoveryCodesResponseData>

    struct CreateResponseData: Codable {
        public let totpId: User.TOTP.ID
        public let secret: String
        public let qrCode: String
        public let recoveryCodes: [String]
        public let user: User
        public let userId: User.ID
    }

    struct RecoverResponseData: Codable, AuthenticateResponseDataType {
        public let userId: User.ID
        public let totpId: User.TOTP.ID
        public let user: User
        public let session: Session
        public let sessionToken: String
        public let sessionJwt: String
    }

    struct RecoveryCodesResponseData: Codable {
        public let userId: User.ID
        public let totps: [Union<User.TOTP, RecoveryCodes>]
    }

    struct RecoveryCodes: Codable {
        public let recoveryCodes: [String]
    }
}
