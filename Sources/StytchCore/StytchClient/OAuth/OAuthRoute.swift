enum OAuthRoute: RouteType {
    case apple(AppleRoute)
    case facebook(FacebookRoute)
    case google(GoogleRoute)

    var path: Path {
        switch self {
        case let .apple(route):
            return "apple".appendingPath(route.path)
        case let .facebook(route):
            return "facebook".appendingPath(route.path)
        case let .google(route):
            return "google".appendingPath(route.path)
        }
    }
}
