import AuthenticationServices
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.OAuth.ThirdParty {
    /// The interface for interacting with OAuth products.
    var discovery: Discovery {
        .init(provider: provider)
    }
}

public extension StytchB2BClient.OAuth.ThirdParty {
    // sourcery: ExcludeWatchOS
    struct Discovery {
        let provider: Provider

        @available(tvOS 16.0, *) // Comments must be below attributes
        // sourcery: AsyncVariants, ExcludeWatchOS (NOTE: - must use /// doc comment styling)
        /// Initiates the OAuth flow by using the included parameters to generate a URL and start an `ASWebAuthenticationSession`.
        /// **NOTE:** The user will be prompted for permission to use "stytch.com" to sign in — you may want to inform your users of this expectation.
        /// The user will see an in-app browser—with shared sessions from their default browser—which will dismiss after completing the authentication challenge with the identity provider.
        ///
        /// **Usage:**
        /// ``` swift
        /// let (token, url) = try await StytchB2BClient.oauth.discovery.google.start(parameters: parameters)
        /// let authResponse = try await StytchB2BClient.oauth.discovery.authenticate(parameters: .init(token: token))
        /// // You can parse the returned `url` value to understand whether this authentication was a login or a signup.
        /// ```
        /// - Returns: A tuple containing an authentication token, for use in the ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd`` method as well as the redirect url to inform whether this authentication was a login or signup.
        public func start(configuration: WebAuthenticationConfiguration) async throws -> (token: String, url: URL) {
            let parameters = try configuration.webAuthenticationSessionClientParameters(providerName: provider.rawValue)
            return try await Current.webAuthenticationSessionClient.initiate(parameters: parameters)
        }
    }
}

public extension StytchB2BClient.OAuth.ThirdParty.Discovery {
    struct WebAuthenticationConfiguration: WebAuthenticationSessionClientConfiguration {
        let discoveryRedirectUrl: URL?
        let customScopes: [String]?
        let providerParams: [String: String]?
        public let clientType: ClientType = .b2b
        @Dependency(\.pkcePairManager) private var pkcePairManager

        #if !os(tvOS)
        /// You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
        public var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
        #endif

        /// - Parameters:
        ///   - discoveryRedirectUrl: The URL that Stytch redirects to after the OAuth flow is completed for the
        ///     member to perform discovery actions. This URL should be an endpoint in the backend server that verifies the
        ///     request by querying Stytch's /oauth/discovery/authenticate endpoint and finishes the login. The URL should be
        ///     configured as a Discovery URL in the Stytch Dashboard's Redirect URL page. If the field is not specified,
        ///     the default in the Dashboard is used.
        ///   - customScopes: Any additional scopes to be requested from the identity provider.
        ///   - providerParams: An optional mapping of provider specific values to pass through to the OAuth provider
        public init(
            discoveryRedirectUrl: URL? = nil,
            customScopes: [String]? = nil,
            providerParams: [String: String]? = nil
        ) {
            self.discoveryRedirectUrl = discoveryRedirectUrl
            self.customScopes = customScopes
            self.providerParams = providerParams
        }

        public func startUrl(_ providerName: String) throws -> URL {
            guard let publicToken = StytchB2BClient.stytchClientConfiguration?.publicToken else {
                throw StytchSDKError.consumerSDKNotConfigured
            }

            var queryParameters: [String: String] = [
                "pkce_code_challenge": try pkcePairManager.generateAndReturnPKCECodePair().codeChallenge,
                "public_token": publicToken,
            ]

            if let customScopes = customScopes?.joined(separator: " ") {
                queryParameters["custom_scopes"] = customScopes
            }

            if let providerParams {
                let modifiedProviderParams = providerParams.appendingPrefix("provider")
                queryParameters.merge(modifiedProviderParams) { _, new in new }
            }

            if let discoveryRedirectUrl = discoveryRedirectUrl?.absoluteString {
                queryParameters["discovery_redirect_url"] = discoveryRedirectUrl
            }

            let domain = Current.localStorage.stytchDomain(publicToken)
            guard let url = URL(string: "https://\(domain)/v1/b2b/public/oauth/\(providerName)/discovery/start?\(queryParameters.toURLParameters())") else {
                throw StytchSDKError.invalidStartURL
            }

            return url
        }

        public func callbackUrlScheme() throws -> String {
            guard let callbackScheme = discoveryRedirectUrl?.scheme, !callbackScheme.hasPrefix("http") else {
                throw StytchSDKError.invalidRedirectScheme
            }
            return callbackScheme
        }
    }
}
#endif
