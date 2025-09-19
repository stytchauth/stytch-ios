import Combine
@preconcurrency import SwiftyJSON

public extension StytchClient {
    /// The SDK allows you to manage the current user's information, such as fetching the user, viewing the most recent cached version of the user, or deleting existing authentication factors associated with this user.
    struct UserManagement {
        let router: NetworkingRouter<UsersRoute>

        @Dependency(\.sessionManager) private var sessionManager

        @Dependency(\.userStorage) private var userStorage

        /// A publisher that emits changes to the current `User`.
        ///
        /// - Publishes `.available(User, Date)` when a valid user is present, along with the last validation timestamp.
        /// - Publishes `.unavailable(EncryptedUserDefaultsError?)` when no valid user exists.
        ///
        /// This allows subscribers to react to user availability without handling `nil` `User` values directly.
        public var onUserChange: AnyPublisher<StytchObjectInfo<User>, Never> {
            userStorage.onChange
        }

        /// Returns the most-recent cached copy of the user object, if it has already been fetched via another method, else nil.
        public func getSync() -> User? {
            userStorage.object
        }

        // sourcery: AsyncVariants
        /// Fetches the most up-to-date version of the current user.
        public func get() async throws -> UserResponse {
            try await updatingCachedUser {
                try await router.get(route: .index)
            }
        }

        // sourcery: AsyncVariants
        /// Searches for a user by their email address
        public func searchUser(email: String) async throws -> UserSearchResponse {
            let response: UserSearchResponse = try await router.post(
                to: .userSearch,
                parameters: JSON(dictionaryLiteral: ("email", email))
            )
            return response
        }

        // sourcery: AsyncVariants
        public func update(parameters: UpdateParameters) async throws -> NestedUserResponse {
            let response: NestedUserResponse = try await router.put(to: .index, parameters: parameters)
            userStorage.update(response.wrapped.user)
            return response
        }

        // sourcery: AsyncVariants
        /// Deletes, by id, an existing authentication factor associated with the current user.
        public func deleteFactor(_ factor: AuthenticationFactor) async throws -> NestedUserResponse {
            let response: NestedUserResponse
            switch factor {
            case let .biometricRegistration(id):
                response = try await router.delete(route: .factors(.biometricRegistrations(id: id)))
            case let .cryptoWallet(id):
                response = try await router.delete(route: .factors(.cryptoWallets(id: id)))
            case let .email(id):
                response = try await router.delete(route: .factors(.emails(id: id)))
            case let .phoneNumber(id):
                response = try await router.delete(route: .factors(.phoneNumbers(id: id)))
            case let .webAuthnRegistration(id):
                response = try await router.delete(route: .factors(.webAuthNRegistrations(id: id)))
            case let .totp(id):
                response = try await router.delete(route: .factors(.totp(id: id)))
            case let .oauth(id):
                response = try await router.delete(route: .factors(.oauth(id: id)))
            }
            userStorage.update(response.wrapped.user)
            return response
        }

        private func updatingCachedUser(_ performRequest: () async throws -> UserResponse) async rethrows -> UserResponse {
            let response = try await performRequest()
            userStorage.update(response.wrapped)
            return response
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with user-management products.
    static var user: UserManagement { .init(router: router.scopedRouter { $0.users }) }
}

public extension StytchClient.UserManagement {
    /// The response type for user-management calls.
    typealias UserResponse = Response<User>
}

public extension StytchClient.UserManagement {
    typealias NestedUserResponse = Response<UserResponseData>

    struct UserResponseData: Codable, Sendable {
        /// The current user object.
        public let user: User
    }
}

public extension StytchClient.UserManagement {
    typealias UserSearchResponse = Response<UserSearchResponseData>

    enum UserType: String, Codable, Sendable {
        case new
        case password
        case passwordless
    }

    struct UserSearchResponseData: Codable, Sendable {
        public let userType: UserType
    }
}

public extension StytchClient.UserManagement {
    /// The authentication factors which are able to be managed via user-management calls.
    enum AuthenticationFactor: Sendable {
        case biometricRegistration(id: User.BiometricRegistration.ID)
        case cryptoWallet(id: User.CryptoWallet.ID)
        case email(id: User.Email.ID)
        case phoneNumber(id: User.PhoneNumber.ID)
        case webAuthnRegistration(id: User.WebAuthNRegistration.ID)
        case totp(id: User.TOTP.ID)
        case oauth(id: User.Provider.ID)
    }

    struct UpdateParameters: Encodable, Sendable {
        let name: User.Name?
        let untrustedMetadata: JSON?

        /// - Parameters:
        ///   - name: The name of the user.
        ///   - untrustedMetadata: The untrusted_metadata field contains an arbitrary JSON object of application-specific data. Untrusted metadata can be edited by end users directly via the SDK, and cannot be used to store critical information. See the Metadata reference for complete field behavior details.
        public init(name: User.Name? = nil, untrustedMetadata: JSON? = nil) {
            self.name = name
            self.untrustedMetadata = untrustedMetadata
        }
    }
}
