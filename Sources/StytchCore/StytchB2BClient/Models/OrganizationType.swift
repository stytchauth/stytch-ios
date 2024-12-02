import Foundation
@preconcurrency import SwiftyJSON

public protocol OrganizationType: Codable, Sendable {
    /// Globally unique UUID that identifies an organization in the Stytch API.
    var organizationId: Organization.ID { get }
    /// An array of active SSO Connection references.
    var ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]? { get }
    /// The default connection used for SSO when there are multiple active connections.
    var ssoDefaultConnectionId: String? { get }
    /// An array of email domains that allow invites or JIT provisioning for new Members.
    /// This list is enforced when either email_invites or email_jit_provisioning is set to RESTRICTED.
    /// Common domains such as gmail.com are not allowed.
    var emailAllowedDomains: [String]? { get }
    /// The authentication setting that controls how a new Member can be provisioned by authenticating via Email Magic Link.
    var emailJitProvisioning: StytchB2BClient.EmailJitProvisioning? { get }
    /// The authentication setting that controls how a new Member can be invited to an organization by email.
    var emailInvites: StytchB2BClient.EmailInvites? { get }
    /// The setting that controls which authentication methods can be used by Members of an Organization.
    var authMethods: StytchB2BClient.AuthMethods? { get }
    /// An array of allowed authentication methods. This list is enforced when auth_methods is set to RESTRICTED.
    var allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]? { get }
}
