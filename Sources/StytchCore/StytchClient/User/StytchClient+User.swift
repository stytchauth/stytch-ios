public extension StytchClient {
    /// some docs
    struct User {
        let router: NetworkingRouter<UserRoute>

        // TODO: - consider making this sync w/ an NSLock vs an actor
        /// some docs (a cached user, if exists)
        public var user: StytchCore.User? {
            get async {
                await Current.userStorage.user
            }
        }

        // sourcery: AsyncVariants
        /// Some docs
        public func get() async throws -> UserResponse {
            try await updatingCachedUser {
                try await router.get(route: .index)
            }
        }

        // sourcery: AsyncVariants
        /// Some docs
        public func update(_ parameters: UpdateParameters) async throws -> UserResponse {
            try await updatingCachedUser {
                try await router.put(to: .index, parameters: parameters)
            }
        }

        // sourcery: AsyncVariants
        /// Some docs
        public func delete(_ parameters: DeleteParameters) async throws -> UserResponse {
            try await updatingCachedUser {
                switch parameters.factor {
                case let .email(id):
                    return try await router.delete(route: .factors(.emails(id: id)))
                case let .phoneNumber(id):
                    return try await router.delete(route: .factors(.phoneNumbers(id: id)))
                case let .webAuthnRegistration(id):
                    return try await router.delete(route: .factors(.webAuthNRegistrations(id: id)))
                case let .cryptoWallet(id):
                    return try await router.delete(route: .factors(.cryptoWallets(id: id)))
                }
            }
        }

        private func updatingCachedUser(_ performRequest: () async throws -> UserResponse) async throws -> UserResponse {
            let response = try await performRequest()
            await Current.userStorage.set(user: response.wrapped)
            return response
        }
    }
}

public typealias UserResponse = Response<User>

public extension StytchClient {
    /// some docs
    static var user: User { .init(router: router.childRouter(BaseRoute.users)) }
}

public extension StytchClient.User {
    /// some docs
    struct UpdateParameters: Encodable {
        let name: User.Name?
        let emails: [Email]?
        let phoneNumbers: [PhoneNumber]?
        let cryptoWallets: [CryptoWallet]?

        /// some docs
        public init(
            name: User.Name? = nil,
            emails: [Email]? = nil,
            phoneNumbers: [PhoneNumber]? = nil,
            cryptoWallets: [CryptoWallet]? = nil
        ) {
            self.name = name
            self.emails = emails
            self.phoneNumbers = phoneNumbers
            self.cryptoWallets = cryptoWallets
        }
    }

    /// some docs
    struct DeleteParameters {
        let factor: Factor

        /// some docs
        public enum Factor {
            case email(id: User.Email.ID)
            case phoneNumber(id: User.PhoneNumber.ID)
            case webAuthnRegistration(id: User.WebAuthNRegistration.ID)
            case cryptoWallet(id: User.CryptoWallet.ID)
        }
    }
}

public extension StytchClient.User.UpdateParameters {
    /// some docs
    struct Email: Encodable {
        let email: String

        public init(_ email: String) {
            self.email = email
        }
    }

    /// some docs
    struct PhoneNumber: Encodable {
        let phoneNumber: String

        public init(_ phoneNumber: String) {
            self.phoneNumber = phoneNumber
        }
    }

    /// some docs
    struct CryptoWallet: Encodable {
        let address: String
        let type: Kind

        public init(address: String, type: StytchClient.User.UpdateParameters.CryptoWallet.Kind) {
            self.address = address
            self.type = type
        }

        public enum Kind: String, Encodable {
            case ethereum
            case solana
        }
    }
}

final actor UserStorage {
    var user: User?

    func set(user: User?) async {
        self.user = user
    }
}
