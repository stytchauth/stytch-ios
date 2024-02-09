enum CryptoWalletsRoute: RouteType {
    case authenticateStartPrimary
    case authenticateStartSecondary
    case authenticate

    var path: Path {
        switch self {
        case .authenticateStartPrimary:
            return "authenticate/start/primary"
        case .authenticateStartSecondary:
            return "authenticate/start/secondary"
        case .authenticate:
            return "authenticate"
        }
    }
}
