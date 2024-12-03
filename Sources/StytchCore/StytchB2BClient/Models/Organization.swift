import Foundation
@preconcurrency import SwiftyJSON

/// A data type representing an organization of which a member may belong to.
public struct Organization: OrganizationType {
    public typealias ID = Identifier<Self, String>

    private enum CodingKeys: String, CodingKey {
        case organizationId
        case name = "organizationName"
        case slug = "organizationSlug"
        case logoUrl = "organizationLogoUrl"
        case trustedMetadata
        case ssoDefaultConnectionId
        case ssoJitProvisioning
        case ssoJitProvisioningAllowedConnections
        case ssoActiveConnections
        case scimActiveConnection
        case emailAllowedDomains
        case emailJitProvisioning
        case emailInvites
        case oauthTenantJitProvisioning
        case allowedOAuthTenants
        case authMethods
        case allowedAuthMethods
        case mfaMethods
        case allowedMfaMethods
        case mfaPolicy
        case rbacEmailImplicitRoleAssignments
    }

    /// Globally unique UUID that identifies a specific Organization. The organization_id is critical to perform operations on an Organization, so be sure to preserve this value.
    public var id: ID { organizationId }
    /// The name of the Organization. Must be between 1 and 128 characters in length.
    public let name: String
    /// The unique URL slug of the Organization. The slug only accepts alphanumeric characters and the following reserved characters: - . _ ~. Must be between 2 and 128 characters in length.
    public let slug: String
    /// The image URL of the Organization logo.
    public let logoUrl: URL?
    /// Arbitrary JSON for storing application-specific or identity-provider-specific data.
    public let trustedMetadata: JSON
    /// Globally unique UUID that identifies a specific Organization. The organization_id is critical to perform operations on an Organization, so be sure to preserve this value.
    public let organizationId: ID
    /// Default connection used for SSO when there are multiple active connections.
    public let ssoDefaultConnectionId: String?
    /// JIT provisioning setting for SSO.
    public let ssoJitProvisioning: StytchB2BClient.SsoJitProvisioning?
    /// Array of allowed connections for restricted SSO JIT provisioning.
    public let ssoJitProvisioningAllowedConnections: [String]?
    /// Array of active SSO connections.
    public let ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]?
    /// Active SCIM connection.
    public let scimActiveConnection: StytchB2BClient.SCIMActiveConnection?
    /// List of domains that allow invites or JIT provisioning.
    public let emailAllowedDomains: [String]?
    /// JIT provisioning setting for Email Magic Link.
    public let emailJitProvisioning: StytchB2BClient.EmailJitProvisioning?
    /// Email invite setting for the organization.
    public let emailInvites: StytchB2BClient.EmailInvites?
    /// JIT provisioning setting for OAuth tenants.
    public let oauthTenantJitProvisioning: StytchB2BClient.OauthTenantJitProvisioning?
    /// JSON object of allowed OAuth tenants.
    public let allowedOAuthTenants: [String: [String]]?
    /// Authentication methods setting for the organization.
    public let authMethods: StytchB2BClient.AuthMethods?
    /// List of allowed authentication methods when restricted.
    public let allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]?
    /// MFA methods setting for the organization.
    public let mfaMethods: StytchB2BClient.MfaMethods?
    /// List of allowed MFA methods when restricted.
    public let allowedMfaMethods: [StytchB2BClient.MfaMethod]?
    /// MFA policy for the organization.
    public let mfaPolicy: StytchB2BClient.MfaPolicy?
    /// An array of implicit role assignments granted to members in this organization whose emails match the domain. See our {@link https://stytch.com/docs/b2b/guides/rbac/role-assignment RBAC guide} for more information about role assignment.
    public let rbacEmailImplicitRoleAssignments: [StytchB2BClient.RBACEmailImplicitRoleAssignments]?
}

extension Organization: Equatable {
    public static func == (lhs: Organization, rhs: Organization) -> Bool {
        lhs.name == rhs.name &&
            lhs.slug == rhs.slug &&
            lhs.logoUrl == rhs.logoUrl &&
            lhs.trustedMetadata == rhs.trustedMetadata &&
            lhs.organizationId == rhs.organizationId &&
            lhs.ssoDefaultConnectionId == rhs.ssoDefaultConnectionId &&
            lhs.ssoJitProvisioning == rhs.ssoJitProvisioning &&
            lhs.ssoJitProvisioningAllowedConnections == rhs.ssoJitProvisioningAllowedConnections &&
            lhs.ssoActiveConnections == rhs.ssoActiveConnections &&
            lhs.scimActiveConnection == rhs.scimActiveConnection &&
            lhs.emailAllowedDomains == rhs.emailAllowedDomains &&
            lhs.emailJitProvisioning == rhs.emailJitProvisioning &&
            lhs.emailInvites == rhs.emailInvites &&
            lhs.oauthTenantJitProvisioning == rhs.oauthTenantJitProvisioning &&
            lhs.allowedOAuthTenants == rhs.allowedOAuthTenants &&
            lhs.authMethods == rhs.authMethods &&
            lhs.allowedAuthMethods == rhs.allowedAuthMethods &&
            lhs.mfaMethods == rhs.mfaMethods &&
            lhs.allowedMfaMethods == rhs.allowedMfaMethods &&
            lhs.mfaPolicy == rhs.mfaPolicy &&
            lhs.rbacEmailImplicitRoleAssignments == rhs.rbacEmailImplicitRoleAssignments
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
        ssoDefaultConnectionId = try container.decodeIfPresent(String.self, forKey: .ssoDefaultConnectionId)
        ssoJitProvisioning = try container.decodeIfPresent(StytchB2BClient.SsoJitProvisioning.self, forKey: .ssoJitProvisioning)
        ssoJitProvisioningAllowedConnections = try container.decodeIfPresent([String].self, forKey: .ssoJitProvisioningAllowedConnections)
        ssoActiveConnections = try container.decodeIfPresent([StytchB2BClient.SSOActiveConnection].self, forKey: .ssoActiveConnections)
        scimActiveConnection = try container.decodeIfPresent(StytchB2BClient.SCIMActiveConnection.self, forKey: .scimActiveConnection)
        emailAllowedDomains = try container.decodeIfPresent([String].self, forKey: .emailAllowedDomains)
        emailJitProvisioning = try container.decodeIfPresent(StytchB2BClient.EmailJitProvisioning.self, forKey: .emailJitProvisioning)
        emailInvites = try container.decodeIfPresent(StytchB2BClient.EmailInvites.self, forKey: .emailInvites)
        oauthTenantJitProvisioning = try container.decodeIfPresent(StytchB2BClient.OauthTenantJitProvisioning.self, forKey: .oauthTenantJitProvisioning)
        allowedOAuthTenants = try container.decodeIfPresent([String: [String]].self, forKey: .allowedOAuthTenants)
        authMethods = try container.decodeIfPresent(StytchB2BClient.AuthMethods.self, forKey: .authMethods)
        allowedAuthMethods = try container.decodeIfPresent([StytchB2BClient.AllowedAuthMethods].self, forKey: .allowedAuthMethods)
        mfaMethods = try container.decodeIfPresent(StytchB2BClient.MfaMethods.self, forKey: .mfaMethods)
        allowedMfaMethods = try container.decodeIfPresent([StytchB2BClient.MfaMethod].self, forKey: .allowedMfaMethods)
        mfaPolicy = try container.decodeIfPresent(StytchB2BClient.MfaPolicy.self, forKey: .mfaPolicy)
        rbacEmailImplicitRoleAssignments = try container.decodeIfPresent([StytchB2BClient.RBACEmailImplicitRoleAssignments].self, forKey: .rbacEmailImplicitRoleAssignments)
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

public extension Organization {
    var usesSMSMFAOnly: Bool {
        guard mfaMethods == .restricted, let allowedMfaMethods else {
            return false
        }
        return allowedMfaMethods.count == 1 && allowedMfaMethods.contains(.sms)
    }

    var usesTOTPMFAOnly: Bool {
        guard mfaMethods == .restricted, let allowedMfaMethods else {
            return false
        }
        return allowedMfaMethods.count == 1 && allowedMfaMethods.contains(.totp)
    }

    var allMFAMethodsAllowed: Bool {
        mfaMethods == .allAllowed
    }
}
