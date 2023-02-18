import Foundation

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

extension Organization {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        organizationId = try container.decode(ID.self, forKey: .organizationId)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        logoUrl = try? container.decodeIfPresent(URL.self, forKey: .logoUrl)
        trustedMetadata = try container.decode(JSON.self, forKey: .trustedMetadata)
    }
}
