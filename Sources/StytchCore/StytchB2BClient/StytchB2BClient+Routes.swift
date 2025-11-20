// swiftlint:disable file_length
import Foundation

extension StytchB2BClient {
    enum BaseRoute: BaseRouteType {
        case discovery(DiscoveryRoute)
        case magicLinks(MagicLinksRoute)
        case organizations(OrganizationsRoute)
        case passwords(PasswordsRoute)
        case sessions(SessionsRoute)
        case sso(SSORoute)
        case searchManager(SearchManagerRoute)
        case totp(TOTPRoute)
        case otp(OTPRoute)
        case recoveryCodes(RecoveryCodesRoute)
        case oauth(OAuthRoute)
        case scim(SCIMRoute)

        var path: Path {
            switch self {
            default:
                let (base, next) = routeComponents
                return "b2b".appendingPath(base).appendingPath(next.path)
            }
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
            case let .searchManager(route):
                return ("", route)
            case let .totp(route):
                return ("totp", route)
            case let .otp(route):
                return ("otps", route)
            case let .recoveryCodes(route):
                return ("recovery_codes", route)
            case let .oauth(route):
                return ("oauth", route)
            case let .scim(route):
                return ("scim", route)
            }
        }
    }

    enum SSORoute: RouteType {
        case authenticate
        case getConnections
        case discoverConnections
        case deleteConnection(connectionId: String)
        case saml(SAMLRoute)
        case oidc(OIDCRoute)

        var path: Path {
            switch self {
            case .authenticate:
                return "authenticate"
            case .getConnections:
                return ""
            case .discoverConnections:
                return Path(rawValue: "discovery/connections")
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
                    return Path(rawValue: "\(memberId)")
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
        case discovery(DiscoveryRoute)

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
            case let .discovery(route):
                return "discovery".appendingPath(route.path)
            }
        }

        enum DiscoveryRoute: RouteType {
            case resetByEmailStart
            case resetByEmail
            case authenticate

            var path: Path {
                switch self {
                case .resetByEmailStart:
                    return "reset/start"
                case .resetByEmail:
                    return "reset"
                case .authenticate:
                    return "authenticate"
                }
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
        case sms(SMSRoute)
        case email(EmailRoute)

        var path: Path {
            switch self {
            case let .sms(route):
                return "sms".appendingPath(route.path)
            case let .email(route):
                return "email".appendingPath(route.path)
            }
        }

        enum SMSRoute: RouteType {
            case send
            case authenticate

            var path: Path {
                switch self {
                case .send:
                    return "send"
                case .authenticate:
                    return "authenticate"
                }
            }
        }

        enum EmailRoute: RouteType {
            case loginOrSignup
            case authenticate
            case discovery(DiscoveryRoute)

            var path: Path {
                switch self {
                case .loginOrSignup:
                    return "login_or_signup"
                case .authenticate:
                    return "authenticate"
                case let .discovery(route):
                    return "discovery".appendingPath(route.path)
                }
            }

            enum DiscoveryRoute: RouteType {
                case send
                case authenticate

                var path: Path {
                    switch self {
                    case .send:
                        return "send"
                    case .authenticate:
                        return "authenticate"
                    }
                }
            }
        }
    }

    enum RecoveryCodesRoute: RouteType {
        case get
        case rotate
        case recover

        var path: Path {
            switch self {
            case .get:
                return ""
            case .rotate:
                return "rotate"
            case .recover:
                return "recover"
            }
        }
    }

    enum SessionsRoute: String, RouteType {
        case authenticate
        case revoke
        case exchange
        case attest

        var path: Path {
            .init(rawValue: rawValue)
        }
    }

    enum OAuthRoute: RouteType {
        case authenticate
        case discoveryRoute(DiscoveryRoute)

        var path: Path {
            switch self {
            case .authenticate:
                return "authenticate"
            case let .discoveryRoute(route):
                return "discovery".appendingPath(route.path)
            }
        }

        enum DiscoveryRoute: RouteType {
            case authenticate

            var path: Path {
                switch self {
                case .authenticate:
                    return "authenticate"
                }
            }
        }
    }

    enum SCIMRoute: RouteType {
        case createConnection
        case updateConnection(connectionId: String)
        case deleteConnection(connectionId: String)
        case getConnection
        case getConnectionGroups
        case rotateStart
        case rotateComplete
        case rotateCancel

        var path: Path {
            switch self {
            case .createConnection:
                return ""
            case let .updateConnection(connectionId: connectionId):
                return Path(rawValue: connectionId)
            case let .deleteConnection(connectionId: connectionId):
                return Path(rawValue: connectionId)
            case .getConnection:
                return ""
            case .getConnectionGroups:
                return ""
            case .rotateStart:
                return "rotate/start"
            case .rotateComplete:
                return "rotate/complete"
            case .rotateCancel:
                return "rotate/cancel"
            }
        }
    }
}
