enum BaseRoute: RouteType {
    case biometrics(BiometricsRoute)
    case magicLinks(MagicLinksRoute)
    case otps(OneTimePasscodesRoute)
    case passwords(PasswordsRoute)
    case sessions(SessionsRoute)
    case users(UsersRoute)

    var path: Path {
        switch self {
        case let .biometrics(route):
            return "biometrics".appendingPath(route.path)
        case let .magicLinks(route):
            return "magic_links".appendingPath(route.path)
        case let .otps(route):
            return "otps".appendingPath(route.path)
        case let .passwords(route):
            return "passwords".appendingPath(route.path)
        case let .sessions(route):
            return "sessions".appendingPath(route.path)
        case let .users(route):
            return "users".appendingPath(route.path)
        }
    }
}

// A reusable route meant to represent the stage (starting and completing) of a given task corresponding to a parent-route's task.
enum TaskStageRoute: String, RouteType {
    case start
    case complete = ""

    var path: Path { .init(rawValue: rawValue) }
}
