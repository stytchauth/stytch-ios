enum SessionsRoute: String, RouteType {
    case authenticate
    case revoke

    var path: Path {
        .init(rawValue: rawValue)
    }
}
