enum PasswordsRoute: RouteType {
    case create
    case resetByEmail(ResetByEmailRoute)
    case authenticate
    case strengthCheck

    var path: Path {
        switch self {
        case .create:
            return ""
        case let .resetByEmail(route):
            return "email/reset".appendingPath(route.path)
        case .authenticate:
            return "authenticate"
        case .strengthCheck:
            return "strength_check"
        }
    }
}

extension PasswordsRoute {
    enum ResetByEmailRoute: String, RouteType {
        case start
        case complete = ""

        var path: Path { .init(rawValue: rawValue) }
    }
}
