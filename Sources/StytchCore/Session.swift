import Foundation

// TODO: - document
public struct Session: Decodable {
    private enum CodingKeys: String, CodingKey {
        case attributes, authenticationFactors, expiresAt, lastAccessedAt, sessionId, startedAt, userId
    }

    public let attributes: Attributes
    public var authenticationFactors: [AuthenticationFactor] { wrappedAuthenticationFactors }
    public let expiresAt: Date
    public let lastAccessedAt: Date
    public let sessionId: String
    public let startedAt: Date
    public let userId: String
    @LossyArray private var wrappedAuthenticationFactors: [AuthenticationFactor]

    init(
        attributes: Session.Attributes,
        authenticationFactors: [AuthenticationFactor],
        expiresAt: Date,
        lastAccessedAt: Date,
        sessionId: String,
        startedAt: Date,
        userId: String
    ) {
        self.attributes = attributes
        _wrappedAuthenticationFactors = .init(wrappedValue: authenticationFactors)
        self.expiresAt = expiresAt
        self.lastAccessedAt = lastAccessedAt
        self.sessionId = sessionId
        self.startedAt = startedAt
        self.userId = userId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try container.decode(key: .attributes)
        _wrappedAuthenticationFactors = try container.decode(key: .authenticationFactors)
        expiresAt = try container.decode(key: .expiresAt)
        lastAccessedAt = try container.decode(key: .lastAccessedAt)
        sessionId = try container.decode(key: .sessionId)
        startedAt = try container.decode(key: .startedAt)
        userId = try container.decode(key: .userId)
    }
}

#if DEBUG
    extension Session: Encodable {
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(attributes, forKey: .attributes)
            try container.encode(authenticationFactors, forKey: .authenticationFactors)
            try container.encode(expiresAt, forKey: .expiresAt)
            try container.encode(lastAccessedAt, forKey: .lastAccessedAt)
            try container.encode(sessionId, forKey: .sessionId)
            try container.encode(startedAt, forKey: .startedAt)
            try container.encode(userId, forKey: .userId)
        }
    }

    extension Session.Attributes: Encodable {}
#endif

extension Session {
    // TODO: - document
    public struct Attributes: Decodable {
        public let ipAddress: String
        public let userAgent: String
    }

    enum Token {
        case opaque(String)
        case jwt(String)

        var name: String {
            switch self {
            case .jwt:
                return "stytch_session"
            case .opaque:
                return "stytch_session_jwt"
            }
        }

        var value: String {
            switch self {
            case let .jwt(value), let .opaque(value):
                return value
            }
        }
    }
}
