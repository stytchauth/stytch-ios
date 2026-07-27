import Foundation

/// The type of factor used to authenticate a session, e.g. magic link, OTP, etc.
///
/// This models the values consumed within the SDK; any factor type the API returns that is not
/// represented here decodes to `.unknown`, carrying the original raw string as its associated value.
public enum AuthenticationFactorType: Sendable, Equatable {
    case oauth
    case magicLink
    case otp
    case password
    case webauthn
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "oauth":
            self = .oauth
        case "magic_link":
            self = .magicLink
        case "otp":
            self = .otp
        case "password":
            self = .password
        case "webauthn":
            self = .webauthn
        default:
            self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .oauth:
            return "oauth"
        case .magicLink:
            return "magic_link"
        case .otp:
            return "otp"
        case .password:
            return "password"
        case .webauthn:
            return "webauthn"
        case let .unknown(value):
            return value
        }
    }

    public static var primaryFactors: [AuthenticationFactorType] {
        [.oauth, .magicLink, .password]
    }

    public static var secondaryFactors: [AuthenticationFactorType] {
        [.otp, .webauthn]
    }

    public static var fullFactors: [AuthenticationFactorType] {
        [.webauthn]
    }
}
