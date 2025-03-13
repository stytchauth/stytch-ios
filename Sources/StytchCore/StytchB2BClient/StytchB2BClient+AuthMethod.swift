import Foundation

public extension StytchB2BClient {
    enum B2BAuthMethod: String, Codable {
        case emailMagicLinks
        case emailOtp
        case oauth
        case passwords
        case sso
        case unknown
    }
}
