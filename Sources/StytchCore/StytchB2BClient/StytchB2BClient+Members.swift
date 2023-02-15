public extension StytchB2BClient {
    struct Members {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute.MembersRoute>

        public func getSync() -> Member? {
            Current.localStorage.member
        }

        public func get() async throws -> MemberResponse {
            let response: MemberResponse = try await router.get(route: .me)
            Current.localStorage.member = response.member
            return response
        }
    }
}

public extension StytchB2BClient {
    static var member: Members { .init(router: organization.router.scopedRouter { $0.members }) }
}

public extension StytchB2BClient.Members {
    typealias MemberResponse = Response<MemberResponseData>

    struct MemberResponseData: Codable {
        public let member: Member
    }
}
