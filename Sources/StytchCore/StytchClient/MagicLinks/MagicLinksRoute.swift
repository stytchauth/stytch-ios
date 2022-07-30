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

extension MagicLinksRoute {
    enum EmailRoute: String, RouteType {
        case loginOrCreate = "login_or_create"

        var path: Path { .init(rawValue: rawValue) }
    }
}
