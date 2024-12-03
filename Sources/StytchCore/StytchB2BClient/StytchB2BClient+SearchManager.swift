import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with the search manager
    static var searchManager: SearchManager {
        .init(router: router.scopedRouter {
            $0.searchManager
        })
    }
}

public extension StytchB2BClient {
    struct SearchManager {
        let router: NetworkingRouter<SearchManagerRoute>

        // sourcery: AsyncVariants
        /// Search for a member of any organization by their email and organization id
        public func searchMember(searchMemberParameters: SearchMemberParameters) async throws -> SearchMemberResponse {
            try await router.post(to: .searchMember, parameters: searchMemberParameters)
        }

        // sourcery: AsyncVariants
        /// Search for an organization by its slug
        public func searchOrganization(searchOrganizationParameters: SearchOrganizationParameters) async throws -> SearchOrganizationResponse {
            try await router.post(to: .searchOrganization, parameters: searchOrganizationParameters)
        }
    }
}

public extension StytchB2BClient.SearchManager {
    struct SearchMemberParameters: Codable, Sendable {
        let emailAddress: String
        let organizationId: String

        /// - Parameters:
        ///   - emailAddress: The email address of the member to search for.
        ///   - organizationId: The id of the organization the member belongs to.
        public init(emailAddress: String, organizationId: String) {
            self.emailAddress = emailAddress
            self.organizationId = organizationId
        }
    }
}

public extension StytchB2BClient.SearchManager {
    typealias SearchMemberResponse = Response<SearchMemberResponseData>

    struct SearchMemberResponseData: Codable, Sendable {
        /// The matching member.
        public let member: MemberSearchResponse?
    }

    struct MemberSearchResponse: Codable, Sendable {
        public let status: String
        public let name: String
        public let memberPasswordId: String
    }
}

public extension StytchB2BClient.SearchManager {
    struct SearchOrganizationParameters: Codable, Sendable {
        let organizationSlug: String

        /// - Parameter organizationSlug: The URL slug of the Organization to get.
        public init(organizationSlug: String) {
            self.organizationSlug = organizationSlug
        }
    }
}

public extension StytchB2BClient.SearchManager {
    typealias SearchOrganizationResponse = Response<SearchOrganizationResponseData>

    struct SearchOrganizationResponseData: Codable, Sendable {
        /// The matching organization.
        public let organization: OrganizationSearchResponse
    }

    struct OrganizationSearchResponse: OrganizationType {
        /// Globally unique UUID that identifies an organization in the Stytch API.
        public let organizationId: Organization.ID
        /// The name of the organization.
        public let organizationName: String
        /// A URL of the organization's logo.
        public let organizationLogoUrl: String?
        /// An array of active SSO Connection references.
        public let ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]?
        /// The default connection used for SSO when there are multiple active connections.
        public let ssoDefaultConnectionId: String?
        /// An array of email domains that allow invites or JIT provisioning for new Members.
        /// This list is enforced when either email_invites or email_jit_provisioning is set to RESTRICTED.
        /// Common domains such as gmail.com are not allowed.
        public let emailAllowedDomains: [String]?
        /// The authentication setting that controls how a new Member can be provisioned by authenticating via Email Magic Link.
        public let emailJitProvisioning: StytchB2BClient.EmailJitProvisioning?
        /// The authentication setting that controls how a new Member can be invited to an organization by email.
        public let emailInvites: StytchB2BClient.EmailInvites?
        /// The setting that controls which authentication methods can be used by Members of an Organization.
        public let authMethods: StytchB2BClient.AuthMethods?
        /// An array of allowed authentication methods. This list is enforced when auth_methods is set to RESTRICTED.
        public let allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]?
    }
}
