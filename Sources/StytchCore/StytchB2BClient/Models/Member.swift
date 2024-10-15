import Foundation

/// A type defining an organization member; including information about their name, status, the auth factors associated with them, and more.
public struct Member: Codable, Sendable {
    public typealias ID = Identifier<Self, String>

    /// Globally unique UUID that identifies a specific Member. The member_id is critical to perform operations on a Member, so be sure to preserve this value.
    public var id: ID { memberId }
    /// Globally unique UUID that identifies a specific Organization. The organization_id is critical to perform operations on an Organization, so be sure to preserve this value.
    public let organizationId: Organization.ID
    /// The email address of the Member.
    public let emailAddress: String
    /// The status of the Member. The possible values are: pending, invited, active, or deleted.
    public let status: Status
    /// The name of the Member.
    public let name: String
    /// An array of registered SAML Connection or OIDC Connection objects the Member has authenticated with.
    public let ssoRegistrations: [SSORegistration]
    /// An arbitrary JSON object for storing application-specific data or identity-provider-specific data.
    public let trustedMetadata: JSON
    /// An arbitrary JSON object of application-specific data. These fields can be edited directly by the frontend SDK, and should not be used to store critical information. See the Metadata resource (https://stytch.com/docs/b2b/api/metadata) for complete field behavior details.
    public let untrustedMetadata: JSON
    /// Globally unique UUID that identifies a Member's password.
    public let memberPasswordId: String

    let memberId: ID
}

extension Member: Equatable {
    public static func == (lhs: Member, rhs: Member) -> Bool {
        lhs.id == rhs.id &&
            lhs.organizationId == rhs.organizationId &&
            lhs.emailAddress == rhs.emailAddress &&
            lhs.status == rhs.status &&
            lhs.name == rhs.name &&
            lhs.ssoRegistrations == rhs.ssoRegistrations &&
            lhs.trustedMetadata == rhs.trustedMetadata &&
            lhs.untrustedMetadata == rhs.untrustedMetadata &&
            lhs.memberPasswordId == rhs.memberPasswordId
    }
}

public extension Member {
    enum Status: String, Codable, Sendable {
        case pending
        case active
        case deleted
        case unknown

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = .init(rawValue: rawValue) ?? .unknown
        }
    }

    /// The authentication factors which are able to be managed via member-management calls.
    enum AuthenticationFactor {
        case totp
        case phoneNumber
        case password(passwordId: String)
    }
}

/// A type representing a specific SSO registration.
public struct SSORegistration: Codable, Equatable, Sendable {
    public typealias ID = Identifier<Self, String>

    /// The unique ID of an SSO Registration.
    public var id: ID { registrationId }
    /// Globally unique UUID that identifies a specific SSO connection_id for a Member.
    public let connectionId: String
    /// The ID of the member given by the identity provider.
    public let externalId: String
    /// An object for storing SSO attributes brought over from the identity provider.
    public let ssoAttributes: JSON

    let registrationId: ID

    public static func == (lhs: SSORegistration, rhs: SSORegistration) -> Bool {
        lhs.id == rhs.id &&
            lhs.connectionId == rhs.connectionId &&
            lhs.externalId == rhs.externalId &&
            lhs.ssoAttributes == rhs.ssoAttributes
    }
}
