public extension StytchB2BClient {
    /// The SDK allows you to view the member's current organization information, such as fetching (or viewing the most recent cached version) of the current organziation.
    struct Organizations {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute>

        /// Returns the most-recent cached copy of the organization object, if it has already been fetched via another method, else nil.
        public func getSync() -> Organization? {
            Current.localStorage.organization
        }

        // sourcery: AsyncVariants
        /// Fetches the most up-to-date version of the current organization.
        public func get() async throws -> OrganizationResponse {
            let response: OrganizationResponse = try await router.get(route: .base)
            Current.localStorage.organization = response.organization
            return response
        }
    }
}

public extension StytchB2BClient {
    /// The interface for interacting with organizations products.
    static var organization: Organizations { .init(router: router.scopedRouter { $0.organizations }) }
}

public extension StytchB2BClient.Organizations {
    /// The response type for organization calls.
    typealias OrganizationResponse = Response<OrganizationResponseData>

    /// The underlying data for the OrganizationResponse type.
    struct OrganizationResponseData: Codable {
        /// The current organization.
        public let organization: Organization
    }
}
