import Combine
@preconcurrency import SwiftyJSON

public extension StytchB2BClient {
    /// The interface for interacting with member products.
    static var member: Members {
        .init(router: organizations.router.scopedRouter { $0.members })
    }
}

public extension StytchB2BClient {
    /// The SDK allows you to view the current member's information, such as fetching (or viewing the most recent cached version) of the current member.
    struct Members {
        let router: NetworkingRouter<StytchB2BClient.OrganizationsRoute.MembersRoute>

        @Dependency(\.memberStorage) private var memberStorage

        /// A publisher which emits following a change in member status and returns either the member object or nil. You can use this as an indicator to set up or tear down your UI accordingly.
        public var onMemberChange: AnyPublisher<StytchObjectInfo<Member>, Never> {
            memberStorage.onChange
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
    struct MemberResponseData: Codable, Sendable {
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
    struct UpdateParameters: Codable, Sendable {
        let name: String?
        let untrustedMetadata: JSON?
        let mfaEnrolled: Bool?
        let mfaPhoneNumber: String?
        let defaultMfaMethod: String?

        /// - Parameters:
        ///   - name: The name of the Member. If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.info.name action on the stytch.member Resource.
        ///     Alternatively, if the Member Session matches the Member associated with the member_id passed in the request, the authorization check will also allow a Member Session that has permission to perform the update.info.name action on the stytch.self Resource.
        ///   - untrustedMetadata: An arbitrary JSON object of application-specific data. These fields can be edited directly by the frontend SDK, and should not be used to store critical information. See the Metadata resource for complete field behavior details.
        ///     If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.info.untrusted-metadata action on the stytch.member Resource.
        ///     Alternatively, if the Member Session matches the Member associated with the member_id passed in the request, the authorization check will also allow a Member Session that has permission to perform the update.info.untrusted-metadata action on the stytch.self Resource.
        ///   - mfaEnrolled: Sets whether the Member is enrolled in MFA. If true, the Member must complete an MFA step whenever they wish to log in to their Organization. If false, the Member only needs to complete an MFA step if the Organization's MFA policy is set to REQUIRED_FOR_ALL.
        ///     If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.settings.mfa-enrolled action on the stytch.member Resource.
        ///     Alternatively, if the Member Session matches the Member associated with the member_id passed in the request, the authorization check will also allow a Member Session that has permission to perform the update.settings.mfa-enrolled action on the stytch.self Resource.
        ///   - mfaPhoneNumber: Sets the Member's phone number. Throws an error if the Member already has a phone number. To change the Member's phone number, use the Delete member phone number endpoint to delete the Member's existing phone number first.
        ///     If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.info.mfa-phone action on the stytch.member Resource.
        ///     Alternatively, if the Member Session matches the Member associated with the member_id passed in the request, the authorization check will also allow a Member Session that has permission to perform the update.info.mfa-phone action on the stytch.self Resource.
        ///   - defaultMfaMethod: Sets whether the Member is enrolled in MFA. If true, the Member must complete an MFA step whenever they wish to log in to their Organization. If false, the Member only needs to complete an MFA step if the Organization's MFA policy is set to REQUIRED_FOR_ALL.
        ///     If this field is provided and a session header is passed into the request, the Member Session must have permission to perform the update.settings.default-mfa-method action on the stytch.member Resource.
        ///     Alternatively, if the Member Session matches the Member associated with the member_id passed in the request, the authorization check will also allow a Member Session that has permission to perform the update.settings.default-mfa-method action on the stytch.self Resource.
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
