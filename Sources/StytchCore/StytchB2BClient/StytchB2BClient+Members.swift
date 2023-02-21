public extension StytchB2BClient {
    struct Members {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute.MembersRoute>

        /// Returns the most-recent cached copy of the member object, if it has already been fetched via another method, else nil.
        public func getSync() -> Member? {
            Current.localStorage.member
        }

        // sourcery: AsyncVariants
        /// Fetches the most up-to-date version of the current member.
        public func get() async throws -> MemberResponse {
            let response: MemberResponse = try await router.get(route: .me)
            Current.localStorage.member = response.member
            return response
        }
    }
}

public extension StytchB2BClient {
    /// The interface for interacting with member products.
    static var member: Members { .init(router: organization.router.scopedRouter { $0.members }) }
}

public extension StytchB2BClient.Members {
    /// The response type for member calls.
    typealias MemberResponse = Response<MemberResponseData>

    /// The underlying data for the MemberResponse type.
    struct MemberResponseData: Codable {
        /// The current member.
        public let member: Member
    }
}
