import Foundation

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
