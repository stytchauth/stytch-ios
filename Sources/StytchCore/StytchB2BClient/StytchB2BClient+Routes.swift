extension StytchB2BClient {
    enum BaseRoute: BaseRouteType {
        case sessions(SessionsRoute)
        case organizations(OrganizationsRoute)

        var path: Path {
            let base: Path = "b2b"
            switch self {
            case let .sessions(route):
                return base.appendingPath("sessions").appendingPath(route.path)
            case let .organizations(route):
                return base.appendingPath("organizations").appendingPath(route.path)
            }
        }
    }
    enum OrganizationsRoute: RouteType {
        case base
        case members(MembersRoute)

        var path: Path {
            switch self {
            case .base:
                return "me"
            case let .members(route):
                return "members".appendingPath(route.path)
            }
        }

        enum MembersRoute: String, RouteType {
            case me

            var path: Path {
                .init(rawValue: rawValue)
            }
        }
    }
}
