import Foundation

/// A data type representing an organization of which a member may belong to.
public struct Organization: Codable, Sendable {
    public typealias ID = Identifier<Self, String>

    private enum CodingKeys: String, CodingKey {
        case organizationId
        case name = "organizationName"
        case slug = "organizationSlug"
        case logoUrl = "organizationLogoUrl"
        case trustedMetadata
    }

    /// Globally unique UUID that identifies a specific Organization. The organization_id is critical to perform operations on an Organization, so be sure to preserve this value.
    public var id: ID { organizationId }
    /// The name of the Organization. Must be between 1 and 128 characters in length.
    public let name: String
    /// The unique URL slug of the Organization. The slug only accepts alphanumeric characters and the following reserved characters: - . _ ~. Must be between 2 and 128 characters in length.
    public let slug: String
    /// The image URL of the Organization logo.
    public let logoUrl: URL?
    /// An arbitrary JSON object for storing application-specific data or identity-provider-specific data.
    public let trustedMetadata: JSON
    let organizationId: ID
}

extension Organization: Equatable {
    public static func == (lhs: Organization, rhs: Organization) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.slug == rhs.slug &&
            lhs.logoUrl == rhs.logoUrl &&
            lhs.trustedMetadata == rhs.trustedMetadata
    }
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
