enum SessionsRoute: String, RouteType {
    case authenticate
    case revoke
    case exchange

    var path: Path {
        .init(rawValue: rawValue)
    }
}
