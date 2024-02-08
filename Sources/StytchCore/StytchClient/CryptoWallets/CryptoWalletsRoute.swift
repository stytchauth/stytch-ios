enum CryptoWalletsRoute: RouteType {
    case authenticateStart
    case authenticate

    var path: Path {
        switch self {
        case .authenticateStart:
            return "authenticateStart"
        case .authenticate:
            return "authenticate"
        }
    }
}
