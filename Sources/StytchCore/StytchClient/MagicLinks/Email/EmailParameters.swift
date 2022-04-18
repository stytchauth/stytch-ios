import Foundation

public struct EmailParameters: Encodable {
    private enum CodingKeys: String, CodingKey {
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

    public init(
        email: Email,
        loginMagicLinkUrl: URL,
        signupMagicLinkUrl: URL,
        loginExpiration: Minutes,
        signupExpiration: Minutes
    ) {
        self.email = email
        self.loginMagicLinkUrl = loginMagicLinkUrl
        self.signupMagicLinkUrl = signupMagicLinkUrl
        self.loginExpiration = loginExpiration
        self.signupExpiration = signupExpiration
    }
}

public struct EmailTag {}

public typealias Email = Tagged<EmailTag, String>
