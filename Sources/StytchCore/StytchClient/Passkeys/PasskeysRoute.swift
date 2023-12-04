enum PasskeysRoute: RouteType {
    case register
    case registerStart
    case authenticate
    case authenticateStartPrimary
    case authenticateStartSecondary
    case update(id: User.WebAuthNRegistration.ID)

    var path: Path {
        let joinedPath: (Path, String) -> Path = { $0.appendingPath(.init(rawValue: $1)) }
        switch self {
        case .register:
            return "register"
        case .registerStart:
            return "register/start"
        case .authenticate:
            return "authenticate"
        case .authenticateStartPrimary:
            return "authenticate/start/primary"
        case .authenticateStartSecondary:
            return "authenticate/start/secondary"
        case let .update(id):
            return joinedPath("update", id.rawValue)
        }
    }
}
