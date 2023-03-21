import Foundation

/// A type defining a member's session; including information about its validity, expiry, factors associated with this session, and more.
public struct MemberSession: Codable {
    public typealias ID = Identifier<Self, String>

    public var id: ID { memberSessionId }
    public let organizationId: Organization.ID
    public let memberId: Member.ID
    public let startedAt: Date
    public let lastAccessedAt: Date
    public let expiresAt: Date
    public let authenticationFactors: [AuthenticationFactor]
    public let customClaims: JSON?

    let memberSessionId: ID
}
