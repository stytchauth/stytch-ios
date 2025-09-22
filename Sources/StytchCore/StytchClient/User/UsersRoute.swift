enum UsersRoute: RouteType {
    case index
    case userSearch
    case factors(FactorsRoute)

    var path: Path {
        switch self {
        case .index:
            return "me"
        case .userSearch:
            return "search"
        case let .factors(route):
            return route.path
        }
    }
}

extension UsersRoute {
    enum FactorsRoute: RouteType {
        case biometricRegistrations(id: User.BiometricRegistration.ID)
        case cryptoWallets(id: User.CryptoWallet.ID)
        case emails(id: User.Email.ID)
        case phoneNumbers(id: User.PhoneNumber.ID)
        case webAuthNRegistrations(id: User.WebAuthNRegistration.ID)
        case totp(id: User.TOTP.ID)
        case oauth(id: User.Provider.ID)

        var path: Path {
            let joinedPath: (Path, String) -> Path = { $0.appendingPath(.init(rawValue: $1)) }
            switch self {
            case let .biometricRegistrations(id):
                return joinedPath("biometric_registrations", id.rawValue)
            case let .cryptoWallets(id):
                return joinedPath("crypto_wallets", id.rawValue)
            case let .emails(id):
                return joinedPath("emails", id.rawValue)
            case let .phoneNumbers(id):
                return joinedPath("phone_numbers", id.rawValue)
            case let .webAuthNRegistrations(id):
                return joinedPath("webauthn_registrations", id.rawValue)
            case let .totp(id):
                return joinedPath("totps", id.rawValue)
            case let .oauth(id):
                return joinedPath("oauth", id.rawValue)
            }
        }
    }
}
