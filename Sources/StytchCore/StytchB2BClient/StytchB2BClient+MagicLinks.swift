import Foundation

public extension StytchB2BClient {
    /// Magic links can be sent via email and allow for a quick and seamless login experience.
    struct MagicLinks {
        let router: NetworkingRouter<MagicLinksRoute>

        @Dependency(\.keychainClient) private var keychainClient

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps the magic link [authenticate](https://stytch.com/docs/b2b/api/authenticate-magic-link) API endpoint which validates the magic link token passed in. If this method succeeds, the member will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BAuthenticateResponse {
            guard let codeVerifier: String = try? keychainClient.get(.codeVerifierPKCE) else { throw StytchSDKError.missingPKCE }

            return try await router.post(
                to: .authenticate,
                parameters: CodeVerifierParameters(codingPrefix: .pkce, codeVerifier: codeVerifier, wrapped: parameters)
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// The Authenticate Discovery Magic Link method wraps the [authenticate](https://stytch.com/docs/b2b/api/send-discovery-email) discovery magic link API endpoint, which validates the discovery magic link token passed in.
        public func discoveryAuthenticate(parameters: DiscoveryAuthenticateParameters) async throws -> DiscoveryAuthenticateResponse {
            guard let codeVerifier: String = try? keychainClient.get(.codeVerifierPKCE) else { throw StytchSDKError.missingPKCE }

            return try await router.post(
                to: .discoveryAuthenticate,
                parameters: CodeVerifierParameters(codingPrefix: .pkce, codeVerifier: codeVerifier, wrapped: parameters)
            )
        }
    }
}

public extension StytchB2BClient {
    /// The interface for interacting with magic-links products.
    static var magicLinks: MagicLinks { .init(router: router.scopedRouter { $0.magicLinks }) }
}

public extension StytchB2BClient.MagicLinks {
    /// The interface for interacting with email magic links.
    var email: Email { .init(router: router.scopedRouter { $0.email }) }
}

public extension StytchB2BClient.MagicLinks {
    /// The SDK provides methods to send and authenticate magic links that you can connect to your own UI.
    struct Email {
        let router: NetworkingRouter<StytchB2BClient.MagicLinksRoute.EmailRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's email magic link [login_or_signup](https://stytch.com/docs/b2b/api/send-login-signup-email) endpoint. Requests an email magic link for a member to log in or signup depending on the presence and/or status of an existing account.
        public func loginOrSignup(parameters: Parameters) async throws -> BasicResponse {
            let (codeChallenge, codeChallengeMethod) = try StytchB2BClient.generateAndStorePKCE(keychainItem: .codeVerifierPKCE)

            return try await router.post(
                to: .loginOrSignup,
                parameters: CodeChallengedParameters(
                    codingPrefix: .pkce,
                    codeChallenge: codeChallenge,
                    codeChallengeMethod: codeChallengeMethod,
                    wrapped: parameters
                )
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// The Send Discovery Email method wraps the [send discovery email](https://stytch.com/docs/b2b/api/send-discovery-email) API endpoint.
        public func discoverySend(parameters: DiscoveryParameters) async throws -> BasicResponse {
            let (codeChallenge, codeChallengeMethod) = try StytchB2BClient.generateAndStorePKCE(keychainItem: .codeVerifierPKCE)

            return try await router.post(
                to: .discoverySend,
                parameters: CodeChallengedParameters(
                    codingPrefix: .pkce,
                    codeChallenge: codeChallenge,
                    codeChallengeMethod: codeChallengeMethod,
                    wrapped: parameters
                )
            )
        }
    }

    /// A dedicated parameters type for magic links `authenticate` calls.
    struct AuthenticateParameters: Codable {
        private enum CodingKeys: String, CodingKey {
            case sessionDuration = "sessionDurationMinutes"
            case token = "magicLinksToken"
        }

        let token: String
        let sessionDuration: Minutes

        /**
         Initializes the parameters struct
         - Parameters:
           - token: The token extracted from the magic link.
           - sessionDuration: The duration, in minutes, for the requested session. Defaults to 30 minutes.
         */
        public init(token: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }

    /// A dedicated parameters type for Discovery `authenticate` calls.
    struct DiscoveryAuthenticateParameters: Codable {
        private enum CodingKeys: String, CodingKey {
            case token = "discoveryMagicLinksToken"
        }

        let token: String

        /// - Parameter token: The Discovery Email Magic Link token to authenticate.
        public init(token: String) {
            self.token = token
        }
    }
}

public extension StytchB2BClient.MagicLinks.Email {
    /// The dedicated parameters type for `loginOrSignup` calls.
    struct Parameters: Codable {
        private enum CodingKeys: String, CodingKey {
            case organizationId
            case email = "emailAddress"
            case loginRedirectUrl
            case signupRedirectUrl
            case loginTemplateId
            case signupTemplateId
        }

        let organizationId: Organization.ID
        let email: String
        let loginRedirectUrl: URL?
        let signupRedirectUrl: URL?
        let loginTemplateId: String?
        let signupTemplateId: String?

        /**
         Initializes the parameters struct
         - Parameters:
           - organizationId: The ID of the intended organization.
           - email: The email of the member to send the invite magic link to.
           - loginRedirectUrl: The url the member clicks from the login email magic link. This should be a url that your app receives and parses and subsequently send an API request to authenticate the magic link and log in the user. If this value is not passed, the default login redirect URL that you set in your Dashboard is used. If you have not set a default login redirect URL, an error is returned.
           - signupRedirectUrl: The url the member clicks from the sign-up email magic link. This should be a url that your app receives and parses and subsequently send an api request to authenticate the magic link and sign-up the user. If this value is not passed, the default sign-up redirect URL that you set in your Dashboard is used. If you have not set a default sign-up redirect URL, an error is returned.
           - loginTemplateId: Use a custom template for login emails. Your default email template will be used if omitted. The template must be a template using our built-in customizations or a custom HTML email for Magic links - Login.
           - signupTemplateId: Use a custom template for sign-up emails. Your default email template will be used if omitted. The template must be a template using our built-in customizations or a custom HTML email for Magic links - Sign-up.
         */
        public init(
            organizationId: Organization.ID,
            email: String,
            loginRedirectUrl: URL? = nil,
            signupRedirectUrl: URL? = nil,
            loginTemplateId: String? = nil,
            signupTemplateId: String? = nil
        ) {
            self.organizationId = organizationId
            self.email = email
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
            self.loginTemplateId = loginTemplateId
            self.signupTemplateId = signupTemplateId
        }
    }

    /// The dedicated parameters type for discovery magic links send calls.
    struct DiscoveryParameters: Codable {
        private enum CodingKeys: String, CodingKey {
            case email = "emailAddress"
            case locale
            case loginTemplateId
            case redirectUrl = "discoveryRedirectUrl"
        }

        let email: String
        let redirectUrl: URL?
        let loginTemplateId: String?
        let locale: String?

        /// - Parameters:
        ///   - email: The email address to send the discovery Magic Link to.
        ///   - redirectUrl: The URL that the end user clicks from the discovery Magic Link. This URL should be an endpoint in the backend server that verifies the request by querying Stytch's discovery authenticate endpoint and continues the flow. If this value is not passed, the default discovery redirect URL that you set in your Dashboard is used. If you have not set a default discovery redirect URL, an error is returned.
        ///   - loginTemplateId: Use a custom template for discovery emails. By default, it will use your default email template. The template must be from Stytch's built-in customizations or a custom HTML email for Magic Links - Login.
        ///   - locale: Used to determine which language to use when sending the user this delivery method. Parameter is a IETF BCP 47 language tag, e.g. "en". Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(
            email: String,
            redirectUrl: URL? = nil,
            loginTemplateId: String? = nil,
            locale: String? = nil
        ) {
            self.email = email
            self.redirectUrl = redirectUrl
            self.loginTemplateId = loginTemplateId
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.MagicLinks {
    /// The response type for discovery authentciate calls.
    typealias DiscoveryAuthenticateResponse = Response<DiscoveryAuthenticateResponseData>

    /// The underlying data for the DiscoveryAuthenticateResponse type.
    struct DiscoveryAuthenticateResponseData: Codable {
        private enum CodingKeys: String, CodingKey {
            case discoveredOrganizations
            case email = "emailAddress"
            case intermediateSessionToken
        }

        /// The discovered organizations.
        public let discoveredOrganizations: [StytchB2BClient.Discovery.DiscoveredOrganization]
        /// The intermediate session token.
        public let intermediateSessionToken: String
        /// The member's email address.
        public let email: String
    }
}
