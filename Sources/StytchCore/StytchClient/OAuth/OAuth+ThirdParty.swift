import AuthenticationServices
import Foundation

#if !os(watchOS)
public protocol ThirdPartyOAuthProviderProtocol {
    @available(tvOS 16.0, *)
    func start(configuration: StytchClient.OAuth.ThirdParty.WebAuthenticationConfiguration) async throws -> (token: String, url: URL)
}

public extension StytchClient.OAuth {
    // sourcery: ExcludeWatchOS
    struct ThirdParty: ThirdPartyOAuthProviderProtocol {
        /// The SDK provides the ability to integrate with third-party identity providers for OAuth experiences beyond the natively-supported Sign In With Apple flow.
        let provider: Provider

        @available(tvOS 16.0, *) // Comments must be below attributes
        // sourcery: AsyncVariants, ExcludeWatchOS (NOTE: - must use /// doc comment styling)
        /// Initiates the OAuth flow by using the included parameters to generate a URL and start an `ASWebAuthenticationSession`.
        /// **NOTE:** The user will be prompted for permission to use "stytch.com" to sign in — you may want to inform your users of this expectation.
        /// The user will see an in-app browser—with shared sessions from their default browser—which will dismiss after completing the authentication challenge with the identity provider.
        ///
        /// **Usage:**
        /// ``` swift
        /// let (token, url) = try await StytchClient.oauth.google.start(parameters: parameters)
        /// let authResponse = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
        /// // You can parse the returned `url` value to understand whether this authentication was a login or a signup.
        /// ```
        /// - Returns: A tuple containing an authentication token, for use in the ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd`` method as well as the redirect url to inform whether this authentication was a login or signup.
        public func start(configuration: WebAuthenticationConfiguration) async throws -> (token: String, url: URL) {
            let parameters = try configuration.webAuthenticationSessionClientParameters(providerName: provider.rawValue)
            return try await Current.webAuthenticationSessionClient.initiate(parameters: parameters)
        }
    }
}

public extension StytchClient.OAuth.ThirdParty {
    struct WebAuthenticationConfiguration: WebAuthenticationSessionClientConfiguration {
        let loginRedirectUrl: URL?
        let signupRedirectUrl: URL?
        let oauthAttachToken: String?
        let customScopes: [String]?
        let providerParams: [String: String]?
        public let clientType: ClientType = .consumer
        @Dependency(\.pkcePairManager) private var pkcePairManager

        #if !os(tvOS)
        /// You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
        public var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
        #endif

        /// - Parameters:
        ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - oauthAttachToken: A single-use token for connecting the Stytch User selection from an OAuth Attach request to the corresponding OAuth Start request.
        ///   - customScopes: Any additional scopes to be requested from the identity provider.
        ///   - providerParams: An optional mapping of provider specific values to pass through to the OAuth provider
        public init(
            loginRedirectUrl: URL? = nil,
            signupRedirectUrl: URL? = nil,
            oauthAttachToken: String? = nil,
            customScopes: [String]? = nil,
            providerParams: [String: String]? = nil
        ) {
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
            self.oauthAttachToken = oauthAttachToken
            self.customScopes = customScopes
            self.providerParams = providerParams
        }

        public func startUrl(_ providerName: String) throws -> URL {
            guard let publicToken = StytchClient.stytchClientConfiguration?.publicToken else {
                throw StytchSDKError.consumerSDKNotConfigured
            }

            var queryParameters: [String: String] = [
                "code_challenge": try pkcePairManager.generateAndReturnPKCECodePair().codeChallenge,
                "public_token": publicToken,
            ]

            if let customScopes = customScopes?.joined(separator: " ") {
                queryParameters["custom_scopes"] = customScopes
            }

            if let providerParams {
                let modifiedProviderParams = providerParams.appendingPrefix("provider")
                queryParameters.merge(modifiedProviderParams) { _, new in new }
            }

            if let loginRedirectUrl = loginRedirectUrl?.absoluteString {
                queryParameters["login_redirect_url"] = loginRedirectUrl
            }

            if let signupRedirectUrl = signupRedirectUrl?.absoluteString {
                queryParameters["signup_redirect_url"] = signupRedirectUrl
            }

            if let oauthAttachToken = oauthAttachToken, oauthAttachToken.isEmpty == false {
                queryParameters["oauth_attach_token"] = oauthAttachToken
            }

            let domain = Current.localStorage.stytchDomain(publicToken)
            guard let url = URL(string: "https://\(domain)/v1/public/oauth/\(providerName)/start?\(queryParameters.toURLParameters())") else {
                throw StytchSDKError.invalidStartURL
            }

            return url
        }

        public func callbackUrlScheme() throws -> String {
            guard let callbackScheme = loginRedirectUrl?.scheme, callbackScheme == signupRedirectUrl?.scheme, !callbackScheme.hasPrefix("http") else {
                throw StytchSDKError.invalidRedirectScheme
            }
            return callbackScheme
        }
    }
}

public extension StytchClient.OAuth.ThirdParty {
    enum Provider: String, CaseIterable, Codable {
        case amazon
        case bitbucket
        case coinbase
        case discord
        case facebook
        case figma
        case github
        case gitlab
        case google
        case linkedin
        case microsoft
        case salesforce
        case slack
        case snapchat
        case spotify
        case tiktok
        case twitch
        case twitter
        case yahoo
    }
}

public extension StytchClient.OAuth.ThirdParty.Provider {
    var client: StytchClient.OAuth.ThirdParty {
        switch self {
        case .amazon:
            return StytchClient.oauth.amazon
        case .bitbucket:
            return StytchClient.oauth.bitbucket
        case .coinbase:
            return StytchClient.oauth.coinbase
        case .discord:
            return StytchClient.oauth.discord
        case .facebook:
            return StytchClient.oauth.facebook
        case .figma:
            return StytchClient.oauth.figma
        case .github:
            return StytchClient.oauth.github
        case .gitlab:
            return StytchClient.oauth.gitlab
        case .google:
            return StytchClient.oauth.google
        case .linkedin:
            return StytchClient.oauth.linkedin
        case .microsoft:
            return StytchClient.oauth.microsoft
        case .salesforce:
            return StytchClient.oauth.salesforce
        case .slack:
            return StytchClient.oauth.slack
        case .snapchat:
            return StytchClient.oauth.snapchat
        case .spotify:
            return StytchClient.oauth.spotify
        case .tiktok:
            return StytchClient.oauth.tiktok
        case .twitch:
            return StytchClient.oauth.twitch
        case .twitter:
            return StytchClient.oauth.twitter
        case .yahoo:
            return StytchClient.oauth.yahoo
        }
    }
}

#endif
