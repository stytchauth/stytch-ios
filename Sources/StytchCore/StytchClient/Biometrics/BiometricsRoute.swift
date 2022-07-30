enum BiometricsRoute: RouteType {
    case authenticate(TaskStageRoute)
    case register(TaskStageRoute)

    var path: Path {
        switch self {
        case let .authenticate(route):
            return "authenticate".appendingPath(route.path)
        case let .register(route):
            return "register".appendingPath(route.path)
        }
    }
}
