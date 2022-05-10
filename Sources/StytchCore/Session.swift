import Foundation

/**
 A type defining a session; including information about its validity, expiry, factors associated with this session, and more.
 */
public struct Session: Codable {
    private enum CodingKeys: String, CodingKey {
        case attributes, authenticationFactors, expiresAt, lastAccessedAt, sessionId, startedAt, userId
    }

    /// Attributes of this session.
    public let attributes: Attributes
    /// A list of authentication factors associated with this session.
    public var authenticationFactors: [AuthenticationFactor] { wrappedAuthenticationFactors }
    /// The date the session expires.
    public let expiresAt: Date
    /// The date this session was last accessed.
    public let lastAccessedAt: Date
    /// The id for this session.
    public let sessionId: String
    /// The date this session began.
    public let startedAt: Date
    /// The user id associated with this session.
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

public extension Session {
    /**
     A type which contains metadata relating to a session.
     */
    struct Attributes: Codable {
        /// The IP Address associated with a session.
        public let ipAddress: String
        /// The user agent associated with a session.
        public let userAgent: String
    }

    struct Token: Equatable {
        public enum Kind: CaseIterable {
            case opaque
            case jwt

            var name: String {
                switch self {
                case .opaque:
                    return "stytch_session"
                case .jwt:
                    return "stytch_session_jwt"
                }
            }
        }

        let kind: Kind

        let value: String

        var name: String { kind.name }

        private init(kind: Kind, value: String) {
            self.kind = kind
            self.value = value
        }

        public static func jwt(_ value: String) -> Self {
            .init(kind: .jwt, value: value)
        }

        public static func opaque(_ value: String) -> Self {
            .init(kind: .opaque, value: value)
        }
    }
}
