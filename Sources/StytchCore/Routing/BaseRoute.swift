enum BaseRoute: RouteType {
    var path: Path {
        switch self {
        case let .magicLinks(route):
            return "magic_links".appendingPath(route.path)
        case let .passwords(route):
            return "passwords".appendingPath(route.path)
        case let .sessions(route):
            return "sessions".appendingPath(route.path)
        case let .otps(route):
            return "otps".appendingPath(route.path)
        }
    }

    case magicLinks(MagicLinksRoute)
    case otps(OneTimePasscodesRoute)
    case passwords(PasswordsRoute)
    case sessions(SessionsRoute)
}
