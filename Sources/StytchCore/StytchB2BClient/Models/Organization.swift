import Foundation

/// A data type representing an organization of which a member may belong to.
public struct Organization: Codable {
    public typealias ID = Identifier<Self, String>

    private enum CodingKeys: String, CodingKey {
        case organizationId
        case name = "organizationName"
        case slug = "organizationSlug"
        case logoUrl = "organizationLogoUrl"
        case trustedMetadata
    }

    public var id: ID { organizationId }
    public let name: String
    public let slug: String
    public let logoUrl: URL?
    public let trustedMetadata: JSON
    let organizationId: ID
}

public extension Organization {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        organizationId = try container.decode(ID.self, forKey: .organizationId)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        logoUrl = try? container.decodeIfPresent(URL.self, forKey: .logoUrl)
        trustedMetadata = try container.decode(JSON.self, forKey: .trustedMetadata)
    }
}

public extension Organization {
    /// The authentication factors which are able to be managed via member-management calls.
    enum MemberAuthenticationFactor {
        case totp(memberId: String)
        case phoneNumber(memberId: String)
        case password(passwordId: String)
    }
}
