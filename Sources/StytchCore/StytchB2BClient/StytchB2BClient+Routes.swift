extension StytchB2BClient {
    enum BaseRoute: BaseRouteType {
        case magicLinks(MagicLinksRoute)
        case organizations(OrganizationsRoute)
        case passwords(PasswordsRoute)
        case sessions(SessionsRoute)

        var path: Path {
            let (base, next) = routeComponents
            return "b2b".appendingPath(base).appendingPath(next.path)
        }

        private var routeComponents: (base: Path, next: RouteType) {
            switch self {
            case let .magicLinks(route):
                return ("magic_links", route)
            case let .organizations(route):
                return ("organizations", route)
            case let .passwords(route):
                return ("passwords", route)
            case let .sessions(route):
                return ("sessions", route)
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
            // swiftlint:disable:next identifier_name
            case me

            var path: Path {
                .init(rawValue: rawValue)
            }
        }
    }

    enum PasswordsRoute: RouteType {
        case resetByEmail(TaskStageRoute)
        case resetByExistingPassword
        case resetBySession
        case authenticate
        case strengthCheck

        var path: Path {
            switch self {
            case let .resetByEmail(route):
                return "email/reset".appendingPath(route.path)
            case .resetByExistingPassword:
                return "existing_password/reset"
            case .resetBySession:
                return "session/reset"
            case .authenticate:
                return "authenticate"
            case .strengthCheck:
                return "strength_check"
            }
        }
    }
}
