import Foundation

public extension StytchClient {
    enum ConsumerAuthMethod: String, Codable {
        case biometrics
        case crypto
        case emailMagicLinks
        case oauthApple
        case oauth
        case otp
        case passkeys
        case passwords
        case totp
        case unknown
    }
}
