import Foundation
@preconcurrency import SwiftyJSON

/// A type defining an organization member, including information about their name, status, authentication factors, and more.
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
    public let ssoRegistrations: [StytchB2BClient.SSORegistration]
    /// An arbitrary JSON object for storing application-specific data or identity-provider-specific data that should only be updated via API.
    public let trustedMetadata: JSON
    /// An arbitrary JSON object of application-specific data. These fields can be edited directly by the frontend SDK, and should not be used to store critical information. See the Metadata resource (https://stytch.com/docs/b2b/api/metadata) for complete field behavior details.
    public let untrustedMetadata: JSON
    /// Globally unique UUID identifying the member's password.
    public let memberPasswordId: String
    /// Whether the member's email address is verified.
    public let emailAddressVerified: Bool
    /// A list of retired email addresses associated with the member.
    public let retiredEmailAddresses: [StytchB2BClient.RetiredEmailAddress]
    /// Whether the member is a breakglass user, bypassing the organization's authentication settings.
    public let isBreakglass: Bool
    /// Whether the member must complete secondary authentication.
    public let mfaEnrolled: Bool
    /// The member's phone number (if available).
    public let mfaPhoneNumber: String?
    /// Whether the member's phone number is verified.
    public let mfaPhoneNumberVerified: Bool
    /// The member's default MFA method.
    public let defaultMfaMethod: String
    /// Globally unique UUID identifying a TOTP instance for the member.
    public let totpRegistrationId: String

    let memberId: ID

    public var mfaMethod: StytchB2BClient.MfaMethod? {
        switch defaultMfaMethod {
        case "sms_otp":
            return .sms
        case "totp":
            return .totp
        default:
            return nil
        }
    }

    /**
     TODO: Missing!
     A list of the member's roles and their sources
     roles: MemberRole[];
     */
}

extension Member: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.organizationId == rhs.organizationId &&
            lhs.id == rhs.id &&
            lhs.emailAddress == rhs.emailAddress &&
            lhs.emailAddressVerified == rhs.emailAddressVerified &&
            lhs.retiredEmailAddresses == rhs.retiredEmailAddresses &&
            lhs.status == rhs.status &&
            lhs.name == rhs.name &&
            lhs.trustedMetadata == rhs.trustedMetadata &&
            lhs.untrustedMetadata == rhs.untrustedMetadata &&
            lhs.ssoRegistrations == rhs.ssoRegistrations &&
            lhs.isBreakglass == rhs.isBreakglass &&
            lhs.memberPasswordId == rhs.memberPasswordId &&
            lhs.mfaEnrolled == rhs.mfaEnrolled &&
            lhs.mfaPhoneNumber == rhs.mfaPhoneNumber &&
            lhs.mfaPhoneNumberVerified == rhs.mfaPhoneNumberVerified &&
            lhs.defaultMfaMethod == rhs.defaultMfaMethod &&
            lhs.totpRegistrationId == rhs.totpRegistrationId
    }
}

public extension Member {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        organizationId = try container.decode(Organization.ID.self, forKey: .organizationId)
        memberId = try container.decode(ID.self, forKey: .memberId)
        emailAddress = try container.decode(String.self, forKey: .emailAddress)
        emailAddressVerified = try container.decode(Bool.self, forKey: .emailAddressVerified)
        retiredEmailAddresses = try container.decodeIfPresent([StytchB2BClient.RetiredEmailAddress].self, forKey: .retiredEmailAddresses) ?? []
        status = try container.decode(Status.self, forKey: .status)
        name = try container.decode(String.self, forKey: .name)
        trustedMetadata = try container.decode(JSON.self, forKey: .trustedMetadata)
        untrustedMetadata = try container.decode(JSON.self, forKey: .untrustedMetadata)
        ssoRegistrations = try container.decodeIfPresent([StytchB2BClient.SSORegistration].self, forKey: .ssoRegistrations) ?? []
        isBreakglass = try container.decode(Bool.self, forKey: .isBreakglass)
        memberPasswordId = try container.decode(String.self, forKey: .memberPasswordId)
        mfaEnrolled = try container.decode(Bool.self, forKey: .mfaEnrolled)
        mfaPhoneNumber = try container.decodeIfPresent(String.self, forKey: .mfaPhoneNumber)
        mfaPhoneNumberVerified = try container.decode(Bool.self, forKey: .mfaPhoneNumberVerified)
        defaultMfaMethod = try container.decode(String.self, forKey: .defaultMfaMethod)
        totpRegistrationId = try container.decode(String.self, forKey: .totpRegistrationId)
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
