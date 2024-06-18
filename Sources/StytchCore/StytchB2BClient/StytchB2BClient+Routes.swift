extension StytchB2BClient {
    enum BaseRoute: BaseRouteType {
        case discovery(DiscoveryRoute)
        case magicLinks(MagicLinksRoute)
        case organizations(OrganizationsRoute)
        case passwords(PasswordsRoute)
        case sessions(B2BSessionsRoute)
        case sso(SSORoute)
        case events(EventsRoute)
        case bootstrap(BootstrapRoute)
        case searchManager(SearchManagerRoute)
        case totp(TOTPRoute)
        case otp(OTPRoute)

        var path: Path {
            let (base, next) = routeComponents
            return "b2b".appendingPath(base).appendingPath(next.path)
        }

        private var routeComponents: (base: Path, next: RouteType) {
            switch self {
            case let .discovery(route):
                return ("discovery", route)
            case let .magicLinks(route):
                return ("magic_links", route)
            case let .organizations(route):
                return ("organizations", route)
            case let .passwords(route):
                return ("passwords", route)
            case let .sessions(route):
                return ("sessions", route)
            case let .sso(route):
                return ("sso", route)
            case let .bootstrap(route):
                return ("", route)
            case let .events(route):
                return ("", route)
            case let .searchManager(route):
                return ("", route)
            case let .totp(route):
                return ("totp", route)
            case let .otp(route):
                return ("otps", route)
            }
        }
    }

    enum SSORoute: RouteType {
        case authenticate
        case getConnections
        case deleteConnection(connectionId: String)
        case saml(SAMLRoute)
        case oidc(OIDCRoute)

        var path: Path {
            switch self {
            case .authenticate:
                return "authenticate"
            case .getConnections:
                return ""
            case let .deleteConnection(connectionId):
                return Path(rawValue: "\(connectionId)")
            case let .saml(route):
                return "saml".appendingPath(route.path)
            case let .oidc(route):
                return "oidc".appendingPath(route.path)
            }
        }

        enum SAMLRoute: RouteType {
            case createConnection
            case updateConnection(connectionId: String)
            case updateConnectionByURL(connectionId: String)
            case deleteVerificationCertificate(connectionId: String, certificateId: String)

            var path: Path {
                switch self {
                case .createConnection:
                    return ""
                case let .updateConnection(connectionId):
                    return Path(rawValue: "\(connectionId)")
                case let .updateConnectionByURL(connectionId):
                    return Path(rawValue: "\(connectionId)/url")
                case let .deleteVerificationCertificate(connectionId, certificateId):
                    return Path(rawValue: "\(connectionId)/verification_certificates/\(certificateId)")
                }
            }
        }

        enum OIDCRoute: RouteType {
            case createConnection
            case updateConnection(connectionId: String)

            var path: Path {
                switch self {
                case .createConnection:
                    return ""
                case let .updateConnection(connectionId):
                    return Path(rawValue: "\(connectionId)")
                }
            }
        }
    }

    enum DiscoveryRoute: RouteType {
        case organizations
        case intermediateSessionsExchange
        case organizationsCreate

        var path: Path {
            switch self {
            case .organizations:
                return "organizations"
            case .organizationsCreate:
                return "organizations/create"
            case .intermediateSessionsExchange:
                return "intermediate_sessions/exchange"
            }
        }
    }

    enum MagicLinksRoute: RouteType {
        case authenticate
        case discoveryAuthenticate
        case email(EmailRoute)

        var path: Path {
            switch self {
            case .authenticate:
                return "authenticate"
            case .discoveryAuthenticate:
                return "discovery/authenticate"
            case let .email(route):
                return "email".appendingPath(route.path)
            }
        }

        enum EmailRoute: RouteType {
            case discoverySend
            case loginOrSignup
            case invite

            var path: Path {
                switch self {
                case .discoverySend:
                    return "discovery/send"
                case .loginOrSignup:
                    return "login_or_signup"
                case .invite:
                    return "invite"
                }
            }
        }
    }

    enum OrganizationsRoute: RouteType {
        case base
        case searchMembers
        case members(MembersRoute)
        case organizationMembers(OrganizationMembersRoute)

        var path: Path {
            switch self {
            case .base:
                return "me"
            case .searchMembers:
                return Path(rawValue: "me/members/search")
            case let .members(route):
                return "members".appendingPath(route.path)
            case let .organizationMembers(route):
                return "members".appendingPath(route.path)
            }
        }

        enum MembersRoute: RouteType {
            // swiftlint:disable:next identifier_name
            case me
            case update
            case deletePhoneNumber
            case deleteTOTP
            case deletePassword(passwordId: String)

            var path: Path {
                switch self {
                case .me:
                    return Path(rawValue: "me")
                case .update:
                    return Path(rawValue: "update")
                case .deletePhoneNumber:
                    return Path(rawValue: "deletePhoneNumber")
                case .deleteTOTP:
                    return Path(rawValue: "deleteTOTP")
                case let .deletePassword(passwordId):
                    return Path(rawValue: "passwords/\(passwordId)")
                }
            }
        }

        enum OrganizationMembersRoute: RouteType {
            case create
            case update(memberId: String)
            case delete(memberId: String)
            case reactivate(memberId: String)
            case deletePhoneNumber(memberId: String)
            case deleteTOTP(memberId: String)
            case deletePassword(passwordId: String)

            var path: Path {
                switch self {
                case .create:
                    return Path(rawValue: "")
                case let .update(memberId):
                    return Path(rawValue: "update/\(memberId)")
                case let .delete(memberId):
                    return Path(rawValue: "\(memberId)")
                case let .reactivate(memberId):
                    return Path(rawValue: "\(memberId)/reactivate")
                case let .deletePhoneNumber(memberId):
                    return Path(rawValue: "deletePhoneNumber/\(memberId)")
                case let .deleteTOTP(memberId):
                    return Path(rawValue: "deleteTOTP/\(memberId)")
                case let .deletePassword(passwordId):
                    return Path(rawValue: "passwords/\(passwordId)")
                }
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

    enum BootstrapRoute: RouteType {
        case fetch(Path)

        var path: Path {
            switch self {
            case let .fetch(publicToken):
                return "projects/bootstrap".appendingPath(publicToken)
            }
        }
    }

    enum SearchManagerRoute: RouteType {
        case searchMember
        case searchOrganization

        var path: Path {
            switch self {
            case .searchMember:
                return "organizations/members/search"
            case .searchOrganization:
                return "organizations/search"
            }
        }
    }

    enum TOTPRoute: RouteType {
        case create
        case authenticate

        var path: Path {
            switch self {
            case .create:
                return ""
            case .authenticate:
                return "authenticate"
            }
        }
    }

    enum OTPRoute: RouteType {
        case send
        case authenticate

        var path: Path {
            switch self {
            case .send:
                return "sms/send"
            case .authenticate:
                return "sms/authenticate"
            }
        }
    }

    enum B2BSessionsRoute: String, RouteType {
        case authenticate
        case revoke
        case exchange

        var path: Path {
            .init(rawValue: rawValue)
        }
    }
}
