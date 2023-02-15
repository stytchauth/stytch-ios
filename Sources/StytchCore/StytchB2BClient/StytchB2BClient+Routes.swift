extension StytchB2BClient {
    enum BaseRoute: BaseRouteType {
        case sessions(SessionsRoute)

        var path: Path {
            let base: Path = "b2b"
            switch self {
            case let .sessions(route):
                return base.appendingPath("sessions").appendingPath(route.path)
            }
        }
    }
