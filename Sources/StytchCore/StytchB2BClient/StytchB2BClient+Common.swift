import Foundation
@preconcurrency import SwiftyJSON

public extension StytchB2BClient {
    /// The authentication setting that controls the JIT provisioning of Members when authenticating via SSO.
    enum SsoJitProvisioning: String, Codable, Sendable {
        /// New Members will be automatically provisioned upon successful authentication via any of the Organization's sso_active_connections.
        case allAllowed = "ALL_ALLOWED"
        /// Only new Members with SSO logins that comply with sso_jit_provisioning_allowed_connections can be provisioned upon authentication.
        case restricted = "RESTRICTED"
        /// Disable JIT provisioning via SSO.
        case notAllowed = "NOT_ALLOWED"
    }

    /// The authentication setting that controls how a new Member can be provisioned by authenticating via Email Magic Link or OAuth.
    enum EmailJitProvisioning: String, Codable, Sendable {
        /// Only new Members with verified emails that comply with email_allowed_domains can be provisioned upon authentication via Email Magic Link or OAuth.
        case restricted = "RESTRICTED"
        /// Disable JIT provisioning via Email Magic Link and OAuth.
        case notAllowed = "NOT_ALLOWED"
    }

    /// The authentication setting that controls how a new Member can be invited to an organization by email.
    enum EmailInvites: String, Codable, Sendable {
        /// Any new Member can be invited to join via email.
        case allAllowed = "ALL_ALLOWED"
        /// Only new Members with verified emails that comply with email_allowed_domains can be invited via email.
        case restricted = "RESTRICTED"
        /// Disable email invites.
        case notAllowed = "NOT_ALLOWED"
    }

    /// The setting that controls which authentication methods can be used by Members of an Organization.
    enum AuthMethods: String, Codable, Sendable {
        /// The default setting which allows all authentication methods to be used.
        case allAllowed = "ALL_ALLOWED"
        /// Only methods that comply with allowed_auth_methods can be used for authentication. This setting does not apply to Members with is_breakglass set to true.
        case restricted = "RESTRICTED"
    }

    /// An array of allowed authentication methods. This list is enforced when auth_methods is set to RESTRICTED. The list's accepted values are: sso, magic_link, password, google_oauth, and microsoft_oauth.
    enum AllowedAuthMethods: String, Codable, Sendable {
        case sso
        case magicLink = "magic_link"
        case password
        case googleOAuth = "google_oauth"
        case microsoftOAuth = "microsoft_oauth"
        case hubspotOAuth = "hubspot_oauth"
        case slackOAuth = "slack_oauth"
        case githubOAuth = "github_oauth"
        case emailOtp = "email_otp"
    }

    /// The setting that controls which MFA methods can be used by Members of an Organization.
    enum MfaMethods: String, Codable, Sendable {
        /// The default setting which allows all authentication methods to be used.
        case allAllowed = "ALL_ALLOWED"
        /// Only methods that comply with allowed_mfa_methods can be used for authentication. This setting does not apply to Members with is_breakglass set to true.
        case restricted = "RESTRICTED"
    }

    /// An array of allowed MFA authentication methods. This list is enforced when mfa_methods is set to RESTRICTED. The list's accepted values are: sms_otp and totp.
    /// If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.settings.allowed-mfa-methods action on the stytch.organization Resource.
    enum MfaMethod: String, Codable, Sendable {
        case sms = "sms_otp"
        case totp
    }

    /// The setting that controls the MFA policy for all Members in the Organization.
    enum MfaPolicy: String, Codable, Sendable {
        /// All Members within the Organization will be required to complete MFA every time they wish to log in. However, any active Session that existed prior to this setting change will remain valid.
        case requiredForAll = "REQUIRED_FOR_ALL"
        /// The default value. The Organization does not require MFA by default for all Members. Members will be required to complete MFA only if their mfa_enrolled status is set to true.
        case optional = "OPTIONAL"
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
    struct RBACEmailImplicitRoleAssignments: Codable, Sendable, Equatable {
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
    struct SSOActiveConnection: Codable, Sendable, Equatable {
        public let connectionId: String
        public let displayName: String

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
        /// Information about the MFA requirements of the Organization and the Member's options for fulfilling MFA.
        public let mfaRequired: StytchB2BClient.MFARequired?
        /// Information about the primary authentication requirements of the Organization.
        public let primaryRequired: StytchB2BClient.PrimaryRequired?
    }

    /// A struct describing a membership and its details.
    struct Membership: Codable, Sendable {
        /// The kind of membership.
        public let type: MembershipType
        /// The details of the membership.
        public let details: JSON?
        /// The member.
        public let member: Member
    }

    enum MembershipType: String, Sendable, Codable {
        case activeMember = "active_member"
        case pendingMember = "pending_member"
        case invitedMember = "invited_member"
        case eligibleToJoinByEmailDomain = "eligible_to_join_by_email_domain"
        case eligibleToJoinByOauthTenant = "eligible_to_join_by_oauth_tenant"
    }

    struct SCIMActiveConnection: Codable, Sendable, Equatable {
        /// The unique identifier of the SCIM connection.
        public let connectionId: String
        /// The human-readable display name of the SCIM connection.
        public let displayName: String
    }

    enum OauthTenantJitProvisioning: String, Codable, Sendable {
        /// Only members from allowed OAuth tenants are allowed to JIT provision.
        case restricted = "RESTRICTED"
        /// JIT provisioning via OAuth is not allowed.
        case notAllowed = "NOT_ALLOWED"
    }

    /// A struct representing a retired email address associated with a member.
    struct RetiredEmailAddress: Codable, Sendable, Equatable {
        /// The unique ID of the retired email (optional).
        public let emailId: String?
        /// The retired email address (optional).
        public let emailAddress: String?
    }

    /// A type representing a specific SSO registration.
    struct SSORegistration: Codable, Equatable, Sendable {
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

    struct PrimaryRequired: Codable, Sendable {
        // Details the auth method that the member must also complete to fulfill the primary authentication requirements of the Organization.
        // For example, a value of [magic_link] indicates that the Member must also complete a magic link authentication step.
        // If you have an intermediate session token, you must pass it into that primary authentication step.
        public let allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]
    }

    struct MFARequired: Codable, Sendable {
        /// Information about the Member's options for completing MFA.
        public let memberOptions: MemberOptions?
        /// If null, indicates that no secondary authentication has been initiated.
        /// If equal to "sms_otp", indicates that the Member has a phone number, and a one time passcode has been sent to the Member's phone number.
        /// No secondary authentication will be initiated during calls to the discovery authenticate or list organizations endpoints, even if the Member has a phone number.
        public let secondaryAuthInitiated: String?
    }

    struct MemberOptions: Codable, Sendable {
        /// The Member's MFA phone number.
        public let mfaPhoneNumber: String
        /// The Member's MFA TOTP registration ID.
        public let totpRegistrationId: String
    }

    enum PasswordStrengthPolicy: String, Codable, Sendable {
        case zxcvbn
        case luds
    }
}

public extension StytchB2BClient {
    typealias DiscoveryAuthenticateResponse = Response<DiscoveryAuthenticateResponseData>

    struct DiscoveryAuthenticateResponseData: DiscoveryIntermediateSessionTokenDataType, Codable, Sendable {
        /// The Intermediate Session Token. This token does not necessarily belong to a specific instance of a Member, but represents a bag of factors that may be converted to a member session.
        /// The token can be used with the OTP SMS Authenticate endpoint, TOTP Authenticate endpoint, or Recovery Codes Recover endpoint to complete an MFA flow and log in to the Organization.
        /// It can also be used with the Exchange Intermediate Session endpoint to join a specific Organization that allows the factors represented by the intermediate session token;
        /// or the Create Organization via Discovery endpoint to create a new Organization and Member.
        public let intermediateSessionToken: String
        /// The email address.
        public let emailAddress: String
        /// An array of discovered_organization objects tied to the intermediate_session_token, session_token, or session_jwt. See the Discovered Organization Object for complete details.
        /// Note that Organizations will only appear here under any of the following conditions:
        /// The end user is already a Member of the Organization.
        /// The end user is invited to the Organization.
        /// The end user can join the Organization because:
        /// a) The Organization allows JIT provisioning.
        /// b) The Organizations' allowed domains list contains the Member's email domain.
        /// c) The Organization has at least one other Member with a verified email address with the same domain as the end user (to prevent phishing attacks).
        public let discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]
    }
}
