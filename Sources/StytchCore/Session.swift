import Foundation

/**
 A type defining a session; including information about its validity, expiry, factors associated with this session, and more.
 */
public struct Session: Decodable {
    public typealias ID = Identifier<Self, String>

    private enum CodingKeys: String, CodingKey {
        case attributes, authenticationFactors, expiresAt, lastAccessedAt, sessionId, startedAt, userId
    }

    /// Attributes of this session.
    public let attributes: Attributes
    /// A list of authentication factors associated with this session.
    public var authenticationFactors: [AuthenticationFactor]
    /// The date the session expires.
    public let expiresAt: Date
    /// The date this session was last accessed.
    public let lastAccessedAt: Date
    /// The id for this session.
    public let sessionId: Session.ID
    /// The date this session began.
    public let startedAt: Date
    /// The user id associated with this session.
    public let userId: User.ID

    init(
        attributes: Session.Attributes,
        authenticationFactors: [AuthenticationFactor],
        expiresAt: Date,
        lastAccessedAt: Date,
        sessionId: Session.ID,
        startedAt: Date,
        userId: User.ID
    ) {
        self.attributes = attributes
        self.authenticationFactors = authenticationFactors
        self.expiresAt = expiresAt
        self.lastAccessedAt = lastAccessedAt
        self.sessionId = sessionId
        self.startedAt = startedAt
        self.userId = userId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try container.decode(key: .attributes)
        authenticationFactors = try container.decode(key: .authenticationFactors)
        expiresAt = try container.decode(key: .expiresAt)
        lastAccessedAt = try container.decode(key: .lastAccessedAt)
        sessionId = try container.decode(key: .sessionId)
        startedAt = try container.decode(key: .startedAt)
        userId = try container.decode(key: .userId)
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

    // TODO: include optional expiration here
    struct Token: Equatable {
        /// A type representing the different kinds of session tokens available.
        public enum Kind: CaseIterable {
            /// An token which is an opaque string, simply representing the session.
            case opaque
            /// A JWT representing the session, which contains signed and serialized information about the session.
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

        /// The kind of session token.
        public let kind: Kind

        /// The string value of the session token.
        public let value: String

        var name: String { kind.name }

        private init(kind: Kind, value: String) {
            self.kind = kind
            self.value = value
        }

        /// Initializes a new token and marks it as a JWT.
        public static func jwt(_ value: String) -> Self {
            .init(kind: .jwt, value: value)
        }

        /// Initializes a new token and marks it as an opaque token.
        public static func opaque(_ value: String) -> Self {
            .init(kind: .opaque, value: value)
        }
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
#endif
