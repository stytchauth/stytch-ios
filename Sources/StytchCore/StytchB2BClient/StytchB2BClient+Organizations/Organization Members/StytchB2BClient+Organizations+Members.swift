import Foundation

public extension StytchB2BClient.Organizations {
    /// The interface for interacting with organization members products.
    var members: Members {
        .init(router: router.scopedRouter { $0.organizationMembers })
    }
}

public extension StytchB2BClient.Organizations {
    struct Members {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute.OrganizationMembersRoute>

        // sourcery: AsyncVariants
        /// Creates a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
        public func create(parameters: CreateParameters) async throws -> OrganizationMemberResponse {
            try await router.post(to: .create, parameters: parameters)
        }

        // sourcery: AsyncVariants
        /// Updates a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
        public func update(parameters: UpdateParameters) async throws -> OrganizationMemberResponse {
            try await router.put(to: .update(memberId: parameters.memberId), parameters: parameters)
        }

        // sourcery: AsyncVariants
        /// Reactivates a deleted Member's status and its associated email status (if applicable) to active.
        /// The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments
        public func reactivate(memberId: String) async throws -> OrganizationMemberResponse {
            try await router.put(to: .reactivate(memberId: memberId), parameters: memberId)
        }

        // sourcery: AsyncVariants
        /// Deletes a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
        public func delete(memberId: String) async throws -> OrganizationMemberDeleteResponse {
            try await router.delete(route: .delete(memberId: memberId))
        }

        // sourcery: AsyncVariants
        /// Deletes a authentication factor from the currently authenticated member.
        public func deleteFactor(factor: Organization.MemberAuthenticationFactor) async throws -> OrganizationMemberResponse {
            let response: OrganizationMemberResponse
            switch factor {
            case let .totp(memberId):
                response = try await router.delete(route: .deleteTOTP(memberId: memberId))
            case let .phoneNumber(memberId):
                response = try await router.delete(route: .deletePhoneNumber(memberId: memberId))
            case let .password(passwordId):
                response = try await router.delete(route: .deletePassword(passwordId: passwordId))
            }
            return response
        }
    }
}

public extension StytchB2BClient.Organizations.Members {
    /// The response type for member calls.
    typealias OrganizationMemberResponse = Response<OrganizationMemberResponseData>

    /// The underlying data for the MemberResponse type.
    struct OrganizationMemberResponseData: Codable {
        /// The current member's member id.
        public let memberId: String?

        /// The current member.
        public let member: Member

        /// The current member's organization.
        public let organization: Organization?
    }
}

public extension StytchB2BClient.Organizations.Members {
    /// The response type for organization member delete calls.
    typealias OrganizationMemberDeleteResponse = Response<OrganizationMemberDeleteResponseData>

    /// The underlying data for the OrganizationMemberDeleteResponse type.
    struct OrganizationMemberDeleteResponseData: Codable {
        /// The current member id that was deleted.
        public let memberId: String
    }
}
