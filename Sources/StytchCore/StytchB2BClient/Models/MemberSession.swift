import Foundation
@preconcurrency import SwiftyJSON

/// A type defining a member's session; including information about its validity, expiry, factors associated with this session, and more.
public struct MemberSession: Codable, Sendable {
    public typealias ID = Identifier<Self, String>

    /// Globally unique UUID that identifies a specific Session in the Stytch API. The member_session_id is critical to perform operations on an Session, so be sure to preserve this value.
    public var id: ID { memberSessionId }
    /// Globally unique UUID that identifies a specific Organization. The organization_id is critical to perform operations on an Organization, so be sure to preserve this value.
    public let organizationId: Organization.ID
    /// Globally unique UUID that identifies a specific Member. The member_id is critical to perform operations on a Member, so be sure to preserve this value.
    public let memberId: Member.ID
    /// The timestamp when the Session started.
    public let startedAt: Date
    /// The timestamp when the Session was last accessed.
    public let lastAccessedAt: Date
    /// The timestamp when the Session will expire.
    public let expiresAt: Date
    /// An array of different authentication factors that comprise a Session.
    public let authenticationFactors: [AuthenticationFactor]
    /// A custom claims map for the Session being authenticated. Claims will be included on the Session object and in the JWT. iss, sub, aud, exp, nbf, iat, jti are reserved claims. Total custom claims size cannot exceed four kilobytes.
    public let customClaims: JSON?
    /// A list of the Roles explicitly or implicitly assigned to this Member that are valid for this Member Session. This may differ from the Roles you see on the Member object - Roles that are implicitly assigned by SSO connection or SSO group will only be valid for a Member Session if there is at least one authentication factor on the Member Session from the specified SSO connection.
    public let roles: [String]?
    /// The unique URL slug of the Organization. The slug only accepts alphanumeric characters and the following reserved characters: - . _ ~. Must be between 2 and 128 characters in length.
    public let organizationSlug: String?

    let memberSessionId: ID
}

extension MemberSession: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
            lhs.organizationId == rhs.organizationId &&
            lhs.memberId == rhs.memberId &&
            lhs.startedAt == rhs.startedAt &&
            lhs.lastAccessedAt == rhs.lastAccessedAt &&
            lhs.expiresAt == rhs.expiresAt &&
            lhs.authenticationFactors == rhs.authenticationFactors &&
            lhs.customClaims == rhs.customClaims &&
            lhs.roles == rhs.roles
    }
}
