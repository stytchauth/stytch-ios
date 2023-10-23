enum PasskeysRoute: String, RouteType {
    case register
    case registerStart = "register/start"
    case authenticate
    case authenticateStartPrimary = "authenticate/start/primary"
    case authenticateStartSecondary = "authenticate/start/secondary"

    var path: Path {
        .init(rawValue: rawValue)
    }
}
