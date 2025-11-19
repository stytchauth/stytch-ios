enum OAuthRoute: RouteType {
    case authenticate
    case attach
    case apple(AppleRoute)

    var path: Path {
        switch self {
        case .authenticate:
            return "authenticate"
        case .attach:
            return "attach"
        case let .apple(route):
            return "apple".appendingPath(route.path)
        }
    }
}

extension OAuthRoute {
    enum AppleRoute: RouteType {
        case authenticate

        var path: Path {
            switch self {
            case .authenticate:
                return "id_token/authenticate"
            }
        }
    }
}
