enum BootstrapRoute: RouteType {
    case fetch(Path)

    var path: Path {
        switch self {
        case let .fetch(publicToken):
            return "projects/bootstrap".appendingPath(publicToken)
        }
    }
}
