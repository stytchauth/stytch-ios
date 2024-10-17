import Foundation
@preconcurrency import SwiftyJSON
// swiftlint:disable identifier_name

public extension StytchB2BClient {
    /// The authentication setting that controls the JIT provisioning of Members when authenticating via SSO.
    enum SsoJitProvisioning: String, Codable, Sendable {
        /// New Members will be automatically provisioned upon successful authentication via any of the Organization's sso_active_connections.
        case ALL_ALLOWED
        /// Only new Members with SSO logins that comply with sso_jit_provisioning_allowed_connections can be provisioned upon authentication.
        case RESTRICTED
        /// Disable JIT provisioning via SSO.
        case NOT_ALLOWED
    }

    /// The authentication setting that controls how a new Member can be provisioned by authenticating via Email Magic Link or OAuth.
    enum EmailJitProvisioning: String, Codable, Sendable {
        /// Only new Members with verified emails that comply with email_allowed_domains can be provisioned upon authentication via Email Magic Link or OAuth.
        case RESTRICTED
        /// Disable JIT provisioning via Email Magic Link and OAuth.
        case NOT_ALLOWED
    }

    /// The authentication setting that controls how a new Member can be invited to an organization by email.
    enum EmailInvites: String, Codable, Sendable {
        /// Any new Member can be invited to join via email.
        case ALL_ALLOWED
        /// Only new Members with verified emails that comply with email_allowed_domains can be invited via email.
        case RESTRICTED
        /// Disable email invites.
        case NOT_ALLOWED
    }

    /// The setting that controls which authentication methods can be used by Members of an Organization.
    enum AuthMethods: String, Codable, Sendable {
        /// The default setting which allows all authentication methods to be used.
        case ALL_ALLOWED
        /// Only methods that comply with allowed_auth_methods can be used for authentication. This setting does not apply to Members with is_breakglass set to true.
        case RESTRICTED
    }

    /// An array of allowed authentication methods. This list is enforced when auth_methods is set to RESTRICTED. The list's accepted values are: sso, magic_link, password, google_oauth, and microsoft_oauth.
    enum AllowedAuthMethods: String, Codable, Sendable {
        case SSO = "sso"
        case MAGIC_LINK = "magic_link"
        case PASSWORD = "password"
        case GOOGLE_OAUTH = "google_oauth"
        case MICROSOFT_OAUTH = "microsoft_oauth"
    }

    /// The setting that controls which MFA methods can be used by Members of an Organization.
    enum MfaMethods: String, Codable, Sendable {
        /// The default setting which allows all authentication methods to be used.
        case ALL_ALLOWED
        /// Only methods that comply with allowed_mfa_methods can be used for authentication. This setting does not apply to Members with is_breakglass set to true.
        case RESTRICTED
    }

    /// An array of allowed MFA authentication methods. This list is enforced when mfa_methods is set to RESTRICTED. The list's accepted values are: sms_otp and totp.
    /// If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.settings.allowed-mfa-methods action on the stytch.organization Resource.
    enum MfaMethod: String, Codable, Sendable {
        case SMS = "sms_otp"
        case TOTP = "totp"
    }

    /// The setting that controls the MFA policy for all Members in the Organization.
    enum MfaPolicy: String, Codable, Sendable {
        /// All Members within the Organization will be required to complete MFA every time they wish to log in. However, any active Session that existed prior to this setting change will remain valid.
        case REQUIRED_FOR_ALL
        /// The default value. The Organization does not require MFA by default for all Members. Members will be required to complete MFA only if their mfa_enrolled status is set to true.
        case OPTIONAL
    }

    /// Sets the Member’s MFA enrollment status upon a successful authentication.
    /// If the Organization’s MFA policy is REQUIRED_FOR_ALL, this field will be ignored.
    /// If this field is not passed in, the Member’s mfa_enrolled boolean will not be affected.
    enum MFAEnrollment: String, Codable, Sendable {
        /// Sets the Member's mfa_enrolled boolean to true. The Member will be required to complete an MFA step upon subsequent logins to the Organization.
        case enroll
        /// Sets the Member's mfa_enrolled boolean to false. The Member will no longer be required to complete MFA steps when logging in to the Organization.
        case unenroll
    }

    /// Implicit role assignments based off of email domains.
    /// For each domain-Role pair, all Members whose email addresses have the specified email domain will be granted the associated Role, regardless of their login method.
    /// See the RBAC guide for more information about role assignment (https://stytch.com/docs/b2b/guides/rbac/role-assignment).
    struct RBACEmailImplicitRoleAssignments: Codable, Sendable {
        let roleId: String
        let domain: String

        /// - Parameters:
        ///   - roleId: The unique identifier of the RBAC Role, provided by the developer and intended to be human-readable.
        ///     Reserved role_ids that are predefined by Stytch include: stytch_member, stytch_admin
        ///     Check out the guide on Stytch default Roles for a more detailed explanation (https://stytch.com/docs/b2b/guides/rbac/stytch-default).
        ///   - domain: Email domain that grants the specified Role.
        public init(roleId: String, domain: String) {
            self.roleId = roleId
            self.domain = domain
        }
    }

    // Information about an active SSO connection
    struct SSOActiveConnection: Codable, Sendable {
        let connectionId: String
        let displayName: String

        /// - Parameters:
        ///   - connectionId: The id of the connection.
        ///   - displayName: The human readable display name of the connection.
        init(connectionId: String, displayName: String) {
            self.connectionId = connectionId
            self.displayName = displayName
        }
    }

    /// A discovered organization.
    struct DiscoveredOrganization: Codable, Sendable {
        /// The Organization object.
        public let organization: Organization
        /// Information about the membership.
        public let membership: Membership
        /// Indicates whether the Member has all of the factors needed to fully authenticate to this Organization. If false, the Member may need to complete an MFA step or complete a different primary authentication flow. See the primary_required and mfa_required fields for more details on each.
        public let memberAuthenticated: Bool
    }

    /// A struct describing a membership and its details.
    struct Membership: Codable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case kind = "type"
            case details
            case member
        }

        /// The kind of membership.
        public let kind: String
        /// The details of the membership.
        public let details: JSON?
        /// The member.
        public let member: Member
    }
}
