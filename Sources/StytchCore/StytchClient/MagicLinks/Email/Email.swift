import Foundation

public extension StytchClient.MagicLinks {
    /// The SDK provides methods to send and authenticate magic links that you can connect to your own UI.
    struct Email {
        let pathContext: Endpoint.Path

        init(pathContext: Endpoint.Path) {
            self.pathContext = pathContext.appendingPathComponent("email")
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's email magic link [login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email) endpoint. Requests an email magic link for a user to log in or create an account depending on the presence and/or status current account.
        public func loginOrCreate(parameters: Parameters, completion: @escaping Completion<BasicResponse>) {
            do {
                let (codeChallenge, codeChallengeMethod) = try StytchClient.generateAndStorePKCE(keychainItem: .stytchEMLPKCECodeVerifier)

                StytchClient.post(
                    to: .init(path: pathContext.appendingPathComponent("login_or_create")),
                    parameters: CodeChallengedParameters(
                        codeChallenge: codeChallenge,
                        codeChallengeMethod: codeChallengeMethod,
                        wrapped: parameters
                    ),
                    completion: completion
                )
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// The interface for interacting with email magic links.
    var email: Email { .init(pathContext: pathContext) }
}

public extension StytchClient.MagicLinks.Email {
    /// The dedicated parameters type for email magic link `loginOrCreate` calls.
    struct Parameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case email
            case loginMagicLinkUrl
            case signupMagicLinkUrl
            case loginExpiration = "login_expiration_minutes"
            case signupExpiration = "signup_expiration_minutes"
        }

        let email: String
        let loginMagicLinkUrl: URL?
        let loginExpiration: Minutes?
        let signupMagicLinkUrl: URL?
        let signupExpiration: Minutes?

        /**
         Initializes the parameters struct
         - Parameters:
           - email: The email of the user to send the invite magic link to.
           - loginMagicLinkUrl: The url the user clicks from the login email magic link. This should be a url that your app receives and parses and subsequently send an API request to authenticate the magic link and log in the user. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
           - loginExpiration: Set the expiration for the login email magic link, in minutes. By default, it expires in 1 hour. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
           - signupMagicLinkUrl: The url the user clicks from the sign-up email magic link. This should be a url that your app receives and parses and subsequently send an api request to authenticate the magic link and sign-up the user. If this value is not passed, the default sign-up redirect URL that you set in your Dashboard is used. If you have not set a default sign-up redirect URL, an error is returned.
           - signupExpiration: Set the expiration for the sign-up email magic link, in minutes. By default, it expires in 1 week. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
         */
        public init(
            email: String,
            loginMagicLinkUrl: URL? = nil,
            loginExpiration: Minutes? = nil,
            signupMagicLinkUrl: URL? = nil,
            signupExpiration: Minutes? = nil
        ) {
            self.email = email
            self.loginMagicLinkUrl = loginMagicLinkUrl
            self.loginExpiration = loginExpiration
            self.signupMagicLinkUrl = signupMagicLinkUrl
            self.signupExpiration = signupExpiration
        }
    }
}
