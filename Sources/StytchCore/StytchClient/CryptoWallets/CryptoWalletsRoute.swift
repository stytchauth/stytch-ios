enum CryptoWalletsRoute: RouteType {
    case authenticateStart
    case authenticate

    var path: Path {
        switch self {
        case .authenticateStart:
            return "authenticate/start/primary"
        case .authenticate:
            return "authenticate"
        }
    }
}
