import Foundation

// swiftlint:disable identifier_name

public extension StytchB2BClient.Organizations {
    /// The dedicated parameters type for the update organization call.
    struct UpdateParameters: Codable {
        let organizationName: String?
        let organizationSlug: String?
        let organizationLogoUrl: String?
        let ssoDefaultConnectionId: String?
        let ssoJitProvisioning: SsoJitProvisioning?
        let ssoJitProvisioningAllowedConnections: [String]?
        let emailAllowedDomains: [String]?
        var emailJitProvisioning: EmailJitProvisioning?
        var emailInvites: EmailInvites?
        var authMethods: AuthMethods?
        var allowedAuthMethods: [AllowedAuthMethods]?
        var mfaMethods: MfaMethods?
        var allowedMfaMethods: [MfaMethod]?
        var mfaPolicy: MfaPolicy?
        var rbacEmailImplicitRoleAssignments: [RBACEmailImplicitRoleAssignments]?

        /// The dedicated parameters type for the update organization call.
        /// - Parameters:
        ///   - organizationName: The name of the organization
        ///   - organizationSlug: The unique URL slug of the Organization. A minimum of two characters is required. The slug only accepts alphanumeric characters and the following reserved characters: - . _ ~.
        ///   - organizationLogoUrl: The image URL of the Organization logo.
        ///   - ssoDefaultConnectionId: The default connection used for SSO when there are multiple active connections.
        ///   - ssoJitProvisioning: The authentication setting that controls the JIT provisioning of Members when authenticating via SSO.
        ///   - ssoJitProvisioningAllowedConnections: An array of connection_ids that reference SAML Connection objects. Only these connections will be allowed to JIT provision Members via SSO when sso_jit_provisioning is set to RESTRICTED.
        ///   - emailAllowedDomains: An array of email domains that allow invites or JIT provisioning for new Members. This list is enforced when either email_invites or email_jit_provisioning is set to RESTRICTED. Common domains such as gmail.com are not allowed.
        ///   - emailJitProvisioning: The authentication setting that controls how a new Member can be provisioned by authenticating via Email Magic Link.
        ///   - emailInvites: The authentication setting that controls how a new Member can be invited to an organization by email.
        ///   - authMethods: The setting that controls which authentication methods can be used by Members of an Organization.
        ///   - allowedAuthMethods: An array of allowed authentication methods.
        ///   - mfaMethods: The setting that controls which mfa methods can be used by Members of an Organization.
        ///   - allowedMfaMethods: An array of allowed MFA methods.
        ///   - mfaPolicy: The setting that controls the MFA policy for all Members in the Organization.
        ///   - rbacEmailImplicitRoleAssignments: rbacEmailImplicitRoleAssignments An array of implicit role assignments granted to members in this organization whose emails match the domain.
        public init(
            organizationName: String? = nil,
            organizationSlug: String? = nil,
            organizationLogoUrl: String? = nil,
            ssoDefaultConnectionId: String? = nil,
            ssoJitProvisioning: StytchB2BClient.Organizations.SsoJitProvisioning? = nil,
            ssoJitProvisioningAllowedConnections: [String]? = nil,
            emailAllowedDomains: [String]? = nil,
            emailJitProvisioning: StytchB2BClient.Organizations.EmailJitProvisioning? = nil,
            emailInvites: StytchB2BClient.Organizations.EmailInvites? = nil,
            authMethods: StytchB2BClient.Organizations.AuthMethods? = nil,
            allowedAuthMethods: [StytchB2BClient.Organizations.AllowedAuthMethods]? = nil,
            mfaMethods: StytchB2BClient.Organizations.MfaMethods? = nil,
            allowedMfaMethods: [StytchB2BClient.Organizations.MfaMethod]? = nil,
            mfaPolicy: StytchB2BClient.Organizations.MfaPolicy? = nil,
            rbacEmailImplicitRoleAssignments: [RBACEmailImplicitRoleAssignments]? = nil
        ) {
            self.organizationName = organizationName
            self.organizationSlug = organizationSlug
            self.organizationLogoUrl = organizationLogoUrl
            self.ssoDefaultConnectionId = ssoDefaultConnectionId
            self.ssoJitProvisioning = ssoJitProvisioning
            self.ssoJitProvisioningAllowedConnections = ssoJitProvisioningAllowedConnections
            self.emailAllowedDomains = emailAllowedDomains
            self.emailJitProvisioning = emailJitProvisioning
            self.emailInvites = emailInvites
            self.authMethods = authMethods
            self.allowedAuthMethods = allowedAuthMethods
            self.mfaMethods = mfaMethods
            self.allowedMfaMethods = allowedMfaMethods
            self.mfaPolicy = mfaPolicy
            self.rbacEmailImplicitRoleAssignments = rbacEmailImplicitRoleAssignments
        }
    }

    enum SsoJitProvisioning: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
        case NOT_ALLOWED
    }

    enum EmailJitProvisioning: String, Codable {
        case RESTRICTED
        case NOT_ALLOWED
    }

    enum EmailInvites: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
        case NOT_ALLOWED
    }

    enum AuthMethods: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
    }

    enum AllowedAuthMethods: String, Codable {
        case SSO = "sso"
        case MAGIC_LINK = "magic_link"
        case PASSWORD = "password"
        case GOOGLE_OAUTH = "google_oauth"
        case MICROSOFT_OAUTH = "microsoft_oauth"
    }

    enum MfaMethods: String, Codable {
        case ALL_ALLOWED
        case RESTRICTED
    }

    enum MfaMethod: String, Codable {
        case SMS = "sms_otp"
        case TOTP = "totp"
    }

    enum MfaPolicy: String, Codable {
        case REQUIRED_FOR_ALL
        case OPTIONAL
    }

    struct RBACEmailImplicitRoleAssignments: Codable {
        var roleId: String
        var domain: String

        public init(roleId: String, domain: String) {
            self.roleId = roleId
            self.domain = domain
        }
    }
}
