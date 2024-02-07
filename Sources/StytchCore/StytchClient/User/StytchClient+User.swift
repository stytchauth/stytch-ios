public extension StytchClient {
    /// The SDK allows you to manage the current user's information, such as fetching the user, viewing the most recent cached version of the user, or deleting existing authentication factors associated with this user.
    struct UserManagement {
        let router: NetworkingRouter<UsersRoute>

        @Dependency(\.localStorage) private var localStorage

        /// Returns the most-recent cached copy of the user object, if it has already been fetched via another method, else nil.
        public func getSync() -> User? {
            localStorage.user
        }

        // sourcery: AsyncVariants
        /// Fetches the most up-to-date version of the current user.
        public func get() async throws -> UserResponse {
            try await updatingCachedUser {
                try await router.get(route: .index)
            }
        }

        // sourcery: AsyncVariants
        public func update(parameters: UpdateParameters) async throws -> UserResponse {
            try await updatingCachedUser {
                try await router.put(to: .index, parameters: parameters)
            }
        }

        // sourcery: AsyncVariants
        /// Deletes, by id, an existing authentication factor associated with the current user.
        public func deleteFactor(_ factor: AuthenticationFactor) async throws -> UserResponse {
            try await updatingCachedUser {
                switch factor {
                case let .biometricRegistration(id):
                    return try await router.delete(route: .factors(.biometricRegistrations(id: id)))
                case let .cryptoWallet(id):
                    return try await router.delete(route: .factors(.cryptoWallets(id: id)))
                case let .email(id):
                    return try await router.delete(route: .factors(.emails(id: id)))
                case let .phoneNumber(id):
                    return try await router.delete(route: .factors(.phoneNumbers(id: id)))
                case let .webAuthnRegistration(id):
                    return try await router.delete(route: .factors(.webAuthNRegistrations(id: id)))
                case let .totp(id):
                    return try await router.delete(route: .factors(.totp(id: id)))
                case let .oauth(id):
                    return try await router.delete(route: .factors(.oauth(id: id)))
                }
            }
        }

        private func updatingCachedUser(_ performRequest: () async throws -> UserResponse) async rethrows -> UserResponse {
            let response = try await performRequest()
            localStorage.user = response.wrapped
            return response
        }
    }
}

public extension StytchClient {
    /// The interface for interacting with user-management products.
    static var user: UserManagement { .init(router: router.scopedRouter { $0.users }) }
}

/// The response type for user-management calls.
public typealias UserResponse = Response<User>

public extension StytchClient.UserManagement {
    /// The authentication factors which are able to be managed via user-management calls.
    enum AuthenticationFactor {
        case biometricRegistration(id: User.BiometricRegistration.ID)
        case cryptoWallet(id: User.CryptoWallet.ID)
        case email(id: User.Email.ID)
        case phoneNumber(id: User.PhoneNumber.ID)
        case webAuthnRegistration(id: User.WebAuthNRegistration.ID)
        case totp(id: User.TOTP.ID)
        case oauth(id: User.Provider.ID)
    }

    struct UpdateParameters: Encodable {
        let name: User.Name?
        let untrustedMetadata: JSON?

        public init(name: User.Name? = nil, untrustedMetadata: JSON? = nil) {
            self.name = name
            self.untrustedMetadata = untrustedMetadata
        }
    }
}
