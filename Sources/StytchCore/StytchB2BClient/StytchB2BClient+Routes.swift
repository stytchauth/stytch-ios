extension StytchB2BClient {
    enum BaseRoute: BaseRouteType {
        case magicLinks(MagicLinksRoute)
        case sessions(SessionsRoute)
        case organizations(OrganizationsRoute)

        var path: Path {
            let base: Path = "b2b"
            switch self {
            case let .magicLinks(route):
                return base.appendingPath("magic_links").appendingPath(route.path)
            case let .sessions(route):
                return base.appendingPath("sessions").appendingPath(route.path)
            case let .organizations(route):
                return base.appendingPath("organizations").appendingPath(route.path)
            }
        }
    }
    enum MagicLinksRoute: RouteType {
        case authenticate
        case email(EmailRoute)

        var path: Path {
            switch self {
            case .authenticate:
                return "authenticate"
            case let .email(route):
                return "email".appendingPath(route.path)
            }
        }

        enum EmailRoute: RouteType {
            case loginOrSignup

            var path: Path {
                switch self {
                case .loginOrSignup:
                    return "login_or_signup"
                }
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
