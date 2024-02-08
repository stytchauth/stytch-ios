enum PasswordsRoute: RouteType {
    case create
    case resetByEmail(TaskStageRoute)
    case authenticate
    case strengthCheck
    case resetBySession
    case resetByExistingPassword

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
        case .resetBySession:
            return "session/reset"
        case .resetByExistingPassword:
            return "existing_password/reset"
        }
    }
}
