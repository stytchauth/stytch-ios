import StytchCore

struct OrganizationManager {
    private static var organization: OrganizationType?

    static var allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]? {
        organization?.allowedAuthMethods
    }

    static var organizationId: Organization.ID? {
        organization?.organizationId
    }

    static var authMethods: StytchB2BClient.AuthMethods? {
        organization?.authMethods
    }

    static var ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]? {
        organization?.ssoActiveConnections
    }

    static var emailAllowedDomains: [String]? {
        organization?.emailAllowedDomains
    }

    static var emailJitProvisioning: StytchB2BClient.EmailJitProvisioning? {
        organization?.emailJitProvisioning
    }

    static func getOrganizationBySlug(organizationSlug: String) async throws {
        let parameters = StytchB2BClient.SearchManager.SearchOrganizationParameters(organizationSlug: organizationSlug)
        let response = try await StytchB2BClient.searchManager.searchOrganization(searchOrganizationParameters: parameters)
        organization = response.organization
    }
}
