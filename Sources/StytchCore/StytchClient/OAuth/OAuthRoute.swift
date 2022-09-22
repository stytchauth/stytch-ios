enum OAuthRoute: RouteType {
    case authenticate
    case apple(AppleRoute)

    var path: Path {
        switch self {
        case .authenticate:
            return "authenticate"
        case let .apple(route):
            return "apple".appendingPath(route.path)
        }
    }
}
