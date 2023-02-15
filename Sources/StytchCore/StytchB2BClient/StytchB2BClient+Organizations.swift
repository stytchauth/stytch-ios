public extension StytchB2BClient {
    struct Organizations {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute>

        public func getSync() -> Organization? {
            Current.localStorage.organization
        }

        public func get() async throws -> OrganizationResponse {
            let response: OrganizationResponse = try await router.get(route: .base)
            Current.localStorage.organization = response.organization
            return response
        }
    }
}

public extension StytchB2BClient {
    static var organization: Organizations { .init(router: router.scopedRouter { $0.organizations }) }
}

public extension StytchB2BClient.Organizations {
    typealias OrganizationResponse = Response<OrganizationResponseData>

    struct OrganizationResponseData: Codable {
        public let organization: Organization
    }
}
