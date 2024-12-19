import Foundation
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

    static var name: String? {
        organization?.name
    }

    static var logoUrl: URL? {
        organization?.logoUrl
    }

    static func getOrganizationBySlug(organizationSlug: String) async throws {
        let parameters = StytchB2BClient.SearchManager.SearchOrganizationParameters(organizationSlug: organizationSlug)
        let response = try await StytchB2BClient.searchManager.searchOrganization(searchOrganizationParameters: parameters)
        organization = response.organization
    }

    static func updateOrganization(_ newOrganization: Organization) {
        organization = newOrganization
    }

    static func reset() {
        organization = nil
    }
}

// All variables in this extension assume the organization object is of type "Organization," not the generic "OrganizationType."
extension OrganizationManager {
    static var usesSMSMFAOnly: Bool? {
        if let org = organization as? Organization {
            return org.usesSMSMFAOnly
        } else {
            return nil
        }
    }

    static var usesTOTPMFAOnly: Bool? {
        if let org = organization as? Organization {
            return org.usesTOTPMFAOnly
        } else {
            return nil
        }
    }

    static var allMFAMethodsAllowed: Bool? {
        if let org = organization as? Organization {
            return org.allMFAMethodsAllowed
        } else {
            return nil
        }
    }

    static var organizationSlug: String? {
        if let org = organization as? Organization {
            return org.slug
        } else {
            return nil
        }
    }
}
