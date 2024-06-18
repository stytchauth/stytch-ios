import Foundation

public extension StytchB2BClient.Organizations {
    /// The dedicated parameters type for the update organization call.
    struct UpdateParameters: Codable {
        let organizationName: String?
        let organizationSlug: String?
        let organizationLogoUrl: String?
        let ssoDefaultConnectionId: String?
        let ssoJitProvisioning: StytchB2BClient.SsoJitProvisioning?
        let ssoJitProvisioningAllowedConnections: [String]?
        let emailAllowedDomains: [String]?
        var emailJitProvisioning: StytchB2BClient.EmailJitProvisioning?
        var emailInvites: StytchB2BClient.EmailInvites?
        var authMethods: StytchB2BClient.AuthMethods?
        var allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]?
        var mfaMethods: StytchB2BClient.MfaMethods?
        var allowedMfaMethods: [StytchB2BClient.MfaMethod]?
        var mfaPolicy: StytchB2BClient.MfaPolicy?
        var rbacEmailImplicitRoleAssignments: [StytchB2BClient.RBACEmailImplicitRoleAssignments]?

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
            ssoJitProvisioning: StytchB2BClient.SsoJitProvisioning? = nil,
            ssoJitProvisioningAllowedConnections: [String]? = nil,
            emailAllowedDomains: [String]? = nil,
            emailJitProvisioning: StytchB2BClient.EmailJitProvisioning? = nil,
            emailInvites: StytchB2BClient.EmailInvites? = nil,
            authMethods: StytchB2BClient.AuthMethods? = nil,
            allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]? = nil,
            mfaMethods: StytchB2BClient.MfaMethods? = nil,
            allowedMfaMethods: [StytchB2BClient.MfaMethod]? = nil,
            mfaPolicy: StytchB2BClient.MfaPolicy? = nil,
            rbacEmailImplicitRoleAssignments: [StytchB2BClient.RBACEmailImplicitRoleAssignments]? = nil
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
}
