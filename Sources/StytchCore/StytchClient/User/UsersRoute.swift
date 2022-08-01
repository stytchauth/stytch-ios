enum UsersRoute: RouteType {
    case index
    case factors(FactorsRoute)

    var path: Path {
        switch self {
        case .index:
            return "me"
        case let .factors(route):
            return route.path
        }
    }
}

extension UsersRoute {
    enum FactorsRoute: RouteType {
        case emails(id: User.Email.ID)
        case phoneNumbers(id: User.PhoneNumber.ID)
        case webAuthNRegistrations(id: User.WebAuthNRegistration.ID)
        case cryptoWallets(id: User.CryptoWallet.ID)

        var path: Path {
            let basePath: Path
            let value: String
            switch self {
            case let .emails(id):
                basePath = "emails"
                value = id.rawValue
            case let .phoneNumbers(id):
                basePath = "phone_numbers"
                value = id.rawValue
            case let .webAuthNRegistrations(id):
                basePath = "webauthn_registrations"
                value = id.rawValue
            case let .cryptoWallets(id):
                basePath = "crypto_wallets"
                value = id.rawValue
            }
            return basePath.appendingPath(.init(rawValue: value))
        }
    }
}
