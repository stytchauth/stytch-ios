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
