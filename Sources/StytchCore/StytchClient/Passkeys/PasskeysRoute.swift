enum PasskeysRoute: String, RouteType {
    case register
    case registerStart = "register/start"
    case authenticate
    case authenticateStart = "authenticate/start"

    var path: Path {
        .init(rawValue: rawValue)
    }
}
