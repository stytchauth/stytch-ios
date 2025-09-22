extension StytchClient {
    enum BaseRoute: BaseRouteType {
        case biometrics(BiometricsRoute)
        case cryptoWallets(CryptoWalletsRoute)
        case magicLinks(MagicLinksRoute)
        case oauth(OAuthRoute)
        case otps(OTPRoute)
        case passkeys(PasskeysRoute)
        case passwords(PasswordsRoute)
        case sessions(SessionsRoute)
        case totp(TOTPRoute)
        case users(UsersRoute)

        var path: Path {
            switch self {
            case let .biometrics(route):
                return "biometrics".appendingPath(route.path)
            case let .cryptoWallets(route):
                return "crypto_wallets".appendingPath(route.path)
            case let .magicLinks(route):
                return "magic_links".appendingPath(route.path)
            case let .oauth(route):
                return "oauth".appendingPath(route.path)
            case let .otps(route):
                return "otps".appendingPath(route.path)
            case let .passkeys(route):
                return "webauthn".appendingPath(route.path)
            case let .passwords(route):
                return "passwords".appendingPath(route.path)
            case let .sessions(route):
                return "sessions".appendingPath(route.path)
            case let .totp(route):
                return "totps".appendingPath(route.path)
            case let .users(route):
                return "users".appendingPath(route.path)
            }
        }
    }
}

// A reusable route meant to represent the stage (starting and completing) of a given task corresponding to a parent-route's task.
enum TaskStageRoute: String, RouteType {
    case start
    case complete = ""

    var path: Path { .init(rawValue: rawValue) }
}
