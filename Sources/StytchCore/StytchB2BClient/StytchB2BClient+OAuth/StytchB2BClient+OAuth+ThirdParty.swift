import AuthenticationServices
import Foundation

#if !os(watchOS)
protocol ThirdPartyB2BOAuthProviderProtocol {
    @available(tvOS 16.0, *)
    func start(configuration: StytchB2BClient.OAuth.ThirdParty.WebAuthenticationConfiguration) async throws -> (token: String, url: URL)
}

public extension StytchB2BClient.OAuth {
    // sourcery: ExcludeWatchOS
    struct ThirdParty: ThirdPartyB2BOAuthProviderProtocol {
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
        /// let (token, url) = try await StytchB2BClient.oauth.google.start(parameters: parameters)
        /// let authResponse = try await StytchB2BClient.oauth.authenticate(parameters: .init(token: token))
        /// // You can parse the returned `url` value to understand whether this authentication was a login or a signup.
        /// ```
        /// - Returns: A tuple containing an authentication token, for use in the ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd`` method as well as the redirect url to inform whether this authentication was a login or signup.
        public func start(configuration: WebAuthenticationConfiguration) async throws -> (token: String, url: URL) {
            let parameters = try configuration.webAuthenticationSessionClientParameters(providerName: provider.rawValue)
            return try await Current.webAuthenticationSessionClient.initiate(parameters: parameters)
        }
    }
}

public extension StytchB2BClient.OAuth.ThirdParty {
    struct WebAuthenticationConfiguration: WebAuthenticationSessionClientConfiguration {
        let loginRedirectUrl: URL?
        let signupRedirectUrl: URL?
        let organizationId: String?
        let organizationSlug: String?
        let customScopes: [String]?
        let providerParams: [String: String]?
        public let clientType: ClientType = .b2b
        @Dependency(\.pkcePairManager) private var pkcePairManager

        #if !os(tvOS)
        /// You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
        public var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
        #endif

        /// - Parameters:
        ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - organizationId: The id of the organization the member belongs to.
        ///   - customScopes: Any additional scopes to be requested from the identity provider.
        ///   - providerParams: An optional mapping of provider specific values to pass through to the OAuth provider
        public init(
            loginRedirectUrl: URL? = nil,
            signupRedirectUrl: URL? = nil,
            organizationId: String? = nil,
            customScopes: [String]? = nil,
            providerParams: [String: String]? = nil
        ) {
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
            self.organizationId = organizationId
            organizationSlug = nil
            self.customScopes = customScopes
            self.providerParams = providerParams
        }

        /// - Parameters:
        ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - organizationSlug: The slug of the organization the member belongs to
        ///   - customScopes: Any additional scopes to be requested from the identity provider.
        ///   - providerParams: An optional mapping of provider specific values to pass through to the OAuth provider
        public init(
            loginRedirectUrl: URL? = nil,
            signupRedirectUrl: URL? = nil,
            organizationSlug: String? = nil,
            customScopes: [String]? = nil,
            providerParams: [String: String]? = nil
        ) {
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
            organizationId = nil
            self.organizationSlug = organizationSlug
            self.customScopes = customScopes
            self.providerParams = providerParams
        }

        public func startUrl(_ providerName: String) throws -> URL {
            guard let publicToken = StytchB2BClient.instance.configuration?.publicToken else {
                throw StytchSDKError.consumerSDKNotConfigured
            }

            let queryParameters: [(String, String?)] = [
                ("pkce_code_challenge", try pkcePairManager.generateAndReturnPKCECodePair().codeChallenge),
                ("public_token", publicToken),
                ("organization_id", organizationId),
                ("slug", organizationSlug),
                ("custom_scopes", customScopes?.joined(separator: " ")),
                ("provider_params", providerParams?.toURLParameters()),
                ("login_redirect_url", loginRedirectUrl?.absoluteString),
                ("signup_redirect_url", signupRedirectUrl?.absoluteString),
            ]

            let domain = Current.localStorage.stytchDomain(publicToken)
            guard let url = URL(string: "https://\(domain)/v1/b2b/public/oauth/\(providerName)/start")?.appending(queryParameters: queryParameters) else {
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

public extension StytchB2BClient.OAuth.ThirdParty {
    enum Provider: String, CaseIterable, Codable {
        case google
        case microsoft
    }
}
#endif
