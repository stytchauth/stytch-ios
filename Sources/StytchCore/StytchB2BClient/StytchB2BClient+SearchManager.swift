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
    struct SearchMemberParameters: Codable {
        public let emailAddress: String
        public let organizationId: String

        public init(emailAddress: String, organizationId: String) {
            self.emailAddress = emailAddress
            self.organizationId = organizationId
        }
    }
}

public extension StytchB2BClient.SearchManager {
    typealias SearchMemberResponse = Response<SearchMemberResponseData>

    struct SearchMemberResponseData: Codable {
        public let member: MemberSearchResponse
    }

    struct MemberSearchResponse: Codable {
        public let status: String
        public let name: String
        public let memberPasswordId: String
    }
}

public extension StytchB2BClient.SearchManager {
    struct SearchOrganizationParameters: Codable {
        public let organizationSlug: String

        public init(organizationSlug: String) {
            self.organizationSlug = organizationSlug
        }
    }
}

public extension StytchB2BClient.SearchManager {
    typealias SearchOrganizationResponse = Response<SearchOrganizationResponseData>

    struct SearchOrganizationResponseData: Codable {
        public let organization: OrganizationSearchResponse
    }

    struct OrganizationSearchResponse: Codable {
        public let organizationId: String
        public let organizationName: String
        public let organizationLogoUrl: String?
        public let ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]?
        public let ssoDefaultConnectionId: String?
        public let emailAllowedDomains: [String]?
        public let emailJitProvisioning: StytchB2BClient.EmailJitProvisioning?
        public let emailInvites: StytchB2BClient.EmailInvites?
        public let authMethods: StytchB2BClient.AuthMethods?
        public let allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]?
    }
}
