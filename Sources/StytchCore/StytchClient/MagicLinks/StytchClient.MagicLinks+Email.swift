import Foundation

public protocol MagicLinksEmailProtocol {
    func loginOrCreate(parameters: StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse
    func send(parameters: StytchClient.MagicLinks.Email.Parameters) async throws -> BasicResponse
}

public extension StytchClient.MagicLinks {
    /// The SDK provides methods to send and authenticate magic links that you can connect to your own UI.
    struct Email: MagicLinksEmailProtocol {
        let router: NetworkingRouter<StytchClient.MagicLinksRoute.EmailRoute>

        @Dependency(\.sessionManager.persistedSessionIdentifiersExist) private var activeSessionExists
        @Dependency(\.pkcePairManager) private var pkcePairManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's email magic link [login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email) endpoint. Requests an email magic link for a user to log in or create an account depending on the presence and/or status of an existing account.
        public func loginOrCreate(parameters: Parameters) async throws -> BasicResponse {
            let pkcePair = try pkcePairManager.generateAndReturnPKCECodePair()

            return try await router.post(
                to: .loginOrCreate,
                parameters: CodeChallengedParameters(
                    codeChallenge: pkcePair.codeChallenge,
                    codeChallengeMethod: pkcePair.method,
                    wrapped: parameters
                ),
                useDFPPA: true
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's email magic link [send](https://stytch.com/docs/api/send-by-email) endpoint. Requests an email magic link for an existing user to log in or attach the included email factor to their current account.
        public func send(parameters: Parameters) async throws -> BasicResponse {
            let pkcePair = try pkcePairManager.generateAndReturnPKCECodePair()

            return try await router.post(
                to: activeSessionExists ? .sendSecondary : .sendPrimary,
                parameters: CodeChallengedParameters(codeChallenge: pkcePair.codeChallenge, codeChallengeMethod: pkcePair.method, wrapped: parameters),
                useDFPPA: true
            )
        }
    }

    /// The interface for interacting with email magic links.
    var email: Email { .init(router: router.scopedRouter { $0.email }) }
}

public extension StytchClient.MagicLinks.Email {
    /// The dedicated parameters type for ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/loginOrCreate(parameters:)-9n8i5`` and ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/send(parameters:)-2i2l1`` calls.
    struct Parameters: Encodable, Equatable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case email
            case loginMagicLinkUrl
            case signupMagicLinkUrl
            case loginExpiration = "loginExpirationMinutes"
            case signupExpiration = "signupExpirationMinutes"
            case loginTemplateId
            case signupTemplateId
            case locale
        }

        let email: String
        let loginMagicLinkUrl: URL?
        let loginExpiration: Minutes?
        let loginTemplateId: String?
        let signupMagicLinkUrl: URL?
        let signupExpiration: Minutes?
        let signupTemplateId: String?
        let locale: StytchLocale?

        /**
         Initializes the parameters struct
         - Parameters:
           - email: The email of the user to send the invite magic link to.
           - loginMagicLinkUrl: The url the user clicks from the login email magic link. This should be a url that your app receives and parses and subsequently send an API request to authenticate the magic link and log in the user. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
           - loginExpiration: Set the expiration for the login email magic link, in minutes. By default, it expires in 1 hour. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
           - loginTemplateId: Use a custom template for login emails. Your default email template will be used if omitted. The template must be a template using our built-in customizations or a custom HTML email for Magic links - Login.
           - signupMagicLinkUrl: The url the user clicks from the sign-up email magic link. This should be a url that your app receives and parses and subsequently send an api request to authenticate the magic link and sign-up the user. If this value is not passed, the default sign-up redirect URL that you set in your Dashboard is used. If you have not set a default sign-up redirect URL, an error is returned.
           - signupExpiration: Set the expiration for the sign-up email magic link, in minutes. By default, it expires in 1 week. The minimum expiration is 5 minutes and the maximum is 7 days (10080 mins).
           - signupTemplateId: Use a custom template for sign-up emails. Your default email template will be used if omitted. The template must be a template using our built-in customizations or a custom HTML email for Magic links - Sign-up.
           - locale: Used to determine which language to use when sending the member this delivery method. Parameter is a IETF BCP 47 language tag, e.g. "en"
         */
        public init(
            email: String,
            loginMagicLinkUrl: URL? = nil,
            loginExpiration: Minutes? = nil,
            loginTemplateId: String? = nil,
            signupMagicLinkUrl: URL? = nil,
            signupExpiration: Minutes? = nil,
            signupTemplateId: String? = nil,
            locale: StytchLocale? = nil
        ) {
            self.email = email
            self.loginMagicLinkUrl = loginMagicLinkUrl
            self.loginExpiration = loginExpiration
            self.loginTemplateId = loginTemplateId
            self.signupMagicLinkUrl = signupMagicLinkUrl
            self.signupExpiration = signupExpiration
            self.signupTemplateId = signupTemplateId
            self.locale = locale
        }

        public static func == (lhs: Parameters, rhs: Parameters) -> Bool {
            lhs.loginMagicLinkUrl == rhs.loginMagicLinkUrl &&
                lhs.loginExpiration == rhs.loginExpiration &&
                lhs.loginTemplateId == rhs.loginTemplateId &&
                lhs.signupMagicLinkUrl == rhs.signupMagicLinkUrl &&
                lhs.signupExpiration == rhs.signupExpiration &&
                lhs.signupTemplateId == rhs.signupTemplateId &&
                lhs.locale == rhs.locale
        }
    }
}
