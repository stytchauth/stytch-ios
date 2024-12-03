import StytchCore

struct OrganizationManager {
    private static var organization: OrganizationType?

    static var organizationId: String? {
        organization?.organizationId.rawValue
    }

    static var ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]? {
        organization?.ssoActiveConnections
    }

    static var ssoDefaultConnectionId: String? {
        organization?.ssoDefaultConnectionId
    }

    static var emailAllowedDomains: [String]? {
        organization?.emailAllowedDomains
    }

    static var emailJitProvisioning: StytchB2BClient.EmailJitProvisioning? {
        organization?.emailJitProvisioning
    }

    static var emailInvites: StytchB2BClient.EmailInvites? {
        organization?.emailInvites
    }

    static var authMethods: StytchB2BClient.AuthMethods? {
        organization?.authMethods
    }

    static var allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]? {
        organization?.allowedAuthMethods
    }

    static func getOrganizationBySlug(organizationSlug: String) async throws {
        let parameters = StytchB2BClient.SearchManager.SearchOrganizationParameters(organizationSlug: organizationSlug)
        let response = try await StytchB2BClient.searchManager.searchOrganization(searchOrganizationParameters: parameters)
        organization = response.organization
    }

    static func updateOrganization(newOrganization: Organization) {
        organization = newOrganization
    }
}
