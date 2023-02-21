extension StytchClient {
    enum MagicLinksRoute: RouteType {
        case authenticate
        case email(EmailRoute)

        var path: Path {
            switch self {
            case .authenticate:
                return "authenticate"
            case let .email(route):
                return "email".appendingPath(route.path)
            }
        }
    }
}

extension StytchClient.MagicLinksRoute {
    enum EmailRoute: String, RouteType {
        case loginOrCreate = "login_or_create"
        case sendPrimary = "send/primary"
        case sendSecondary = "send/secondary"

        var path: Path { .init(rawValue: rawValue) }
    }
}
