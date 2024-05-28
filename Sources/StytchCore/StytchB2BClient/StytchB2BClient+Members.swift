import Combine

public extension StytchB2BClient {
    /// The interface for interacting with member products.
    static var member: Members { .init(router: organizations.router.scopedRouter { $0.members }) }
}

public extension StytchB2BClient {
    /// The SDK allows you to view the current member's information, such as fetching (or viewing the most recent cached version) of the current member.
    struct Members {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute.MembersRoute>

        @Dependency(\.memberStorage) private var memberStorage

        /// A publisher which emits following a change in member status and returns either the member object or nil. You can use this as an indicator to set up or tear down your UI accordingly.
        public var onMemberChange: AnyPublisher<Member?, Never> {
            memberStorage.onChange.eraseToAnyPublisher()
        }

        /// Returns the most-recent cached copy of the member object, if it has already been fetched via another method, else nil.
        public func getSync() -> Member? {
            memberStorage.object
        }

        // sourcery: AsyncVariants
        /// Fetches the most up-to-date version of the current member.
        public func get() async throws -> MemberResponse {
            try await updatingCachedMember {
                try await router.get(route: .me)
            }
        }

        // sourcery: AsyncVariants
        /// Updates the current member.
        public func update(parameters: UpdateParameters) async throws -> MemberResponse {
            try await updatingCachedMember {
                try await router.put(to: .update, parameters: parameters)
            }
        }

        // sourcery: AsyncVariants
        /// Deletes, by id, an existing authentication factor associated with the current member.
        public func deleteFactor(_ factor: Member.AuthenticationFactor) async throws -> MemberResponse {
            let response: MemberResponse
            switch factor {
            case .totp:
                response = try await router.delete(route: .deleteTOTP)
            case .phoneNumber:
                response = try await router.delete(route: .deletePhoneNumber)
            case let .password(passwordId):
                response = try await router.delete(route: .deletePassword(passwordId: passwordId))
            }
            memberStorage.update(response.member)
            return response
        }

        private func updatingCachedMember(_ performRequest: () async throws -> MemberResponse) async rethrows -> MemberResponse {
            let response = try await performRequest()
            memberStorage.update(response.wrapped.member)
            return response
        }
    }
}

public extension StytchB2BClient.Members {
    /// The response type for member calls.
    typealias MemberResponse = Response<MemberResponseData>

    /// The underlying data for the MemberResponse type.
    struct MemberResponseData: Codable {
        /// The current member's member id.
        public let memberId: String?

        /// The current member.
        public let member: Member

        /// The current member's organization.
        public let organization: Organization?
    }
}

public extension StytchB2BClient.Members {
    /// The dedicated parameters type for the update member call.
    struct UpdateParameters: Codable {
        let name: String?
        let untrustedMetadata: JSON?
        let mfaEnrolled: Bool?
        let mfaPhoneNumber: String?
        let defaultMfaMethod: String?

        public init(
            name: String? = nil,
            untrustedMetadata: JSON? = nil,
            mfaEnrolled: Bool? = nil,
            mfaPhoneNumber: String? = nil,
            defaultMfaMethod: String? = nil
        ) {
            self.name = name
            self.untrustedMetadata = untrustedMetadata
            self.mfaEnrolled = mfaEnrolled
            self.mfaPhoneNumber = mfaPhoneNumber
            self.defaultMfaMethod = defaultMfaMethod
        }
    }
}
