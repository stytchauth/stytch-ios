import Combine

public extension StytchB2BClient {
    /// The interface for interacting with organizations products.
    static var organizations: Organizations {
        .init(router: router.scopedRouter { $0.organizations })
    }
}

public extension StytchB2BClient {
    /// The SDK allows you to view the member's current organization information, such as fetching (or viewing the most recent cached version) of the current organziation.
    struct Organizations {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute>

        @Dependency(\.organizationStorage) private var organizationStorage

        /// A publisher which emits following a change in organization status and returns either the organization object or nil. You can use this as an indicator to set up or tear down your UI accordingly.
        public var onOrganizationChange: AnyPublisher<Organization?, Never> {
            organizationStorage.onChange.eraseToAnyPublisher()
        }

        /// Returns the most-recent cached copy of the organization object, if it has already been fetched via another method, else nil.
        public func getSync() -> Organization? {
            organizationStorage.object
        }

        // sourcery: AsyncVariants
        /// Fetches the most up-to-date version of the current organization.
        public func get() async throws -> OrganizationResponse {
            try await updatingCachedOrganization {
                try await router.get(route: .base)
            }
        }

        // sourcery: AsyncVariants
        /// Updates the current organization.
        public func update(updateParameters: UpdateParameters) async throws -> OrganizationResponse {
            try await updatingCachedOrganization {
                try await router.put(to: .base, parameters: updateParameters)
            }
        }

        // sourcery: AsyncVariants
        /// Deletes the current organization. The current member must be an admin.
        public func delete() async throws -> OrganizationDeleteResponse {
            try await router.delete(route: .base)
        }

        // sourcery: AsyncVariants
        /// Search for Members from the caller's organization. Submitting an empty query returns all non-deleted Members.
        /// All fuzzy search filters require a minimum of three characters.
        /// The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
        public func searchMembers(parameters: SearchParameters) async throws -> SearchMembersResponse {
            try await router.post(to: .searchMembers, parameters: parameters)
        }

        private func updatingCachedOrganization(_ performRequest: () async throws -> OrganizationResponse) async rethrows -> OrganizationResponse {
            let response = try await performRequest()
            organizationStorage.update(response.wrapped.organization)
            return response
        }
    }
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

public extension StytchB2BClient.Organizations {
    /// The response type for organization delete calls.
    typealias OrganizationDeleteResponse = Response<OrganizationDeleteResponseData>

    /// The underlying data for the OrganizationDeleteResponse type.
    struct OrganizationDeleteResponseData: Codable {
        /// The current organization id that was deleted.
        public let organizationId: String
    }
}

public extension StytchB2BClient.Organizations {
    typealias SearchMembersResponse = Response<SearchResponseData>

    struct SearchResponseData: Codable {
        // An array of Member objects.
        public let members: [Member]
        // The search results_metadata object contains metadata relevant to your specific query like total and next_cursor.
        public let resultsMetadata: SearchResponseResultsMetadata
        // A map from organization_id to Organization object. The map only contains the Organizations that the Members belongs to.
        public let organizations: [String: Organization]
    }

    struct SearchResponseResultsMetadata: Codable {
        // The total number of results returned by your search query.
        public let total: Int
        // The next_cursor string is returned when your search result contains more than one page of results. This value is passed into your next search call in the cursor field.
        public let nextCursor: String?
    }
}
