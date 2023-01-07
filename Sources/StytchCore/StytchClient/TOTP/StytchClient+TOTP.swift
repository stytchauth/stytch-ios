extension StytchClient {
    public struct TOTP {
        let router: NetworkingRouter<TOTPRoute>

        public func create(parameters: CreateParameters) async throws -> CreateResponse {
            try await router.post(to: .create, parameters: parameters)
        }

        public func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponseType {
            try await router.post(to: .authenticate, parameters: parameters) as AuthenticateResponse
        }

        public func recoveryCodes() async throws -> RecoveryCodesResponse {
            try await router.post(to: .recoveryCodes, parameters: JSON.object([:]))
        }

        public func recover(parameters: RecoverParameters) async throws -> RecoverResponse {
            try await router.post(to: .recover, parameters: parameters)
        }

        public typealias CreateResponse = Response<CreateResponseData>
        public typealias RecoverResponse = Response<RecoverResponseData>
        public typealias RecoveryCodesResponse = Response<RecoveryCodesResponseData>

        public struct CreateResponseData: Codable {
            let totpId: User.TOTP.ID
            let secret: String
            let qrCode: String
            let recoveryCodes: [String]
            let user: User
            let userId: User.ID
        }

        public struct CreateParameters: Encodable {
            enum CodingKeys: String, CodingKey {
                case expiration = "expiration_minutes"
            }

            let expiration: Minutes

            public init(expiration: Minutes = .defaultSessionDuration) {
                self.expiration = expiration
            }
        }

        public struct AuthenticateParameters: Encodable {
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

        public struct RecoverParameters: Encodable {
            enum CodingKeys: String, CodingKey {
                case recoveryCode
                case sessionDuration = "session_duration_minutes"
            }

            let recoveryCode: String
            let sessionDuration: Minutes

            init(recoveryCode: String, sessionDuration: Minutes = .defaultSessionDuration) {
                self.recoveryCode = recoveryCode
                self.sessionDuration = sessionDuration
            }
        }

        public struct RecoverResponseData: Codable, AuthenticateResponseDataType {
            public let userId: User.ID
            public let totpId: User.TOTP.ID
            public let user: User
            public let session: Session
            public let sessionToken: String
            public let sessionJwt: String
        }

        public struct RecoveryCodesResponseData: Codable {
            let userId: User.ID
            let totps: [Union<User.TOTP, TOTPRecoveryCodes>]
        }
    }
}

extension StytchClient {
    public static var totp: TOTP { .init(router: router.scopedRouter(BaseRoute.totp)) }
}

struct TOTPRecoveryCodes: Codable {
    let recoveryCodes: [String]
}

@dynamicMemberLookup
public struct Union<A: Codable, B: Codable>: Codable {
    let a: A
    let b: B

    enum CodingKeys: CodingKey {
        case a
        case b
    }

    public init(from decoder: Decoder) throws {
        self.a = try .init(from: decoder)
        self.b = try .init(from: decoder)
    }

    init(a: A, b: B) {
        self.a = a
        self.b = b
    }

    public func encode(to encoder: Encoder) throws {
        try a.encode(to: encoder)
        try b.encode(to: encoder)
    }

    public subscript<T>(dynamicMember member: KeyPath<A, T>) -> T {
        a[keyPath: member]
    }

    public subscript<T>(dynamicMember member: KeyPath<B, T>) -> T {
        b[keyPath: member]
    }
}

enum TOTPRoute: RouteType {
    case create
    case authenticate
    case recoveryCodes
    case recover

    var path: Path {
        switch self {
        case .create:
            return ""
        case .authenticate:
            return "authenticate"
        case .recoveryCodes:
            return "recovery_codes"
        case .recover:
            return "recover"
        }
    }
}
