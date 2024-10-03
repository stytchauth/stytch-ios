import Foundation

/**
 A type defining a session; including information about its validity, expiry, factors associated with this session, and more.
 */
public struct Session {
    public typealias ID = Identifier<Self, String>

    private enum CodingKeys: String, CodingKey {
        case attributes, authenticationFactors, expiresAt, lastAccessedAt, sessionId, startedAt, userId
    }

    /// Attributes of this session.
    public let attributes: Attributes
    /// A list of authentication factors associated with this session.
    public let authenticationFactors: [AuthenticationFactor]
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
}

extension Session: Equatable {
    public static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.attributes == rhs.attributes &&
            lhs.authenticationFactors == rhs.authenticationFactors &&
            lhs.expiresAt == rhs.expiresAt &&
            lhs.lastAccessedAt == rhs.lastAccessedAt &&
            lhs.sessionId == rhs.sessionId &&
            lhs.startedAt == rhs.startedAt &&
            lhs.userId == rhs.userId
    }
}

extension Session: Codable {
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
    struct Attributes: Codable, Equatable {
        /// The IP Address associated with a session.
        public let ipAddress: String
        /// The user agent associated with a session.
        public let userAgent: String

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            lhs.ipAddress == rhs.ipAddress &&
                lhs.userAgent == rhs.userAgent
        }
    }
}
