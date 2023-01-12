enum TOTPRoute: RouteType {
    case create
    case authenticate
    case recoveryCodes
    case recover

    var path: Path {
        switch self {
        case .create:
            return ""
        case .authenticate:
            return "authenticate"
        case .recoveryCodes:
            return "recovery_codes"
        case .recover:
            return "recover"
        }
    }
}
