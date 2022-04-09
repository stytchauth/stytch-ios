import Foundation

public struct EmailParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case email
        case loginMagicLinkUrl
        case signupMagicLinkUrl
        case loginExpiration = "login_expiration_minutes"
        case signupExpiration = "signup_expiration_minutes"
//        case attributes
    }

    let email: Email
    let loginMagicLinkUrl: URL
    let signupMagicLinkUrl: URL
    let loginExpiration: Minutes
    let signupExpiration: Minutes
//    let attributes: [String: String] // TODO: - confirm what this is and if needed
}

public struct EmailTag {}
public typealias Email = Tagged<EmailTag, String>
