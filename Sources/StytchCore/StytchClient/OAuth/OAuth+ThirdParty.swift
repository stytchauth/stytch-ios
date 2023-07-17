import AuthenticationServices
import Foundation

#if !os(watchOS)
public extension StytchClient.OAuth {
    /// The SDK provides the ability to integrate with third-party identity providers for OAuth experiences beyond the natively-supported Sign In With Apple flow.
    // sourcery: ExcludeWatchOS
    struct ThirdParty {
        let provider: Provider

        @Dependency(\.openUrl) private var openUrl

        @available(tvOS 16.0, *)
        private var webAuthSessionClient: WebAuthenticationSessionClient {
            Current.webAuthSessionClient
        }

        /// Initiates the OAuth flow by using the included parameters to generate a URL and pass this off to the system's default browser. The user will be redirected to the corresponding redirectUrl (this should be back into the application), after completing the authentication challenge with the identity provider.
        @available(*, deprecated)
        public func start(parameters: DefaultBrowserStartParameters) throws {
            let url = try generateStartUrl(
                loginRedirectUrl: parameters.loginRedirectUrl,
                signupRedirectUrl: parameters.signupRedirectUrl,
                customScopes: parameters.customScopes
            )

            openUrl(url)
        }

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
        public func start(parameters: WebAuthSessionStartParameters) async throws -> (token: String, url: URL) {
            guard let callbackScheme = parameters.loginRedirectUrl.scheme, callbackScheme == parameters.signupRedirectUrl.scheme, !callbackScheme.hasPrefix("http") else {
                throw StytchError.oauthInvalidRedirectScheme
            }
            let url = try generateStartUrl(
                loginRedirectUrl: parameters.loginRedirectUrl,
                signupRedirectUrl: parameters.signupRedirectUrl,
                customScopes: parameters.customScopes
            )
            #if !os(tvOS)
            let webClientParams: WebAuthenticationSessionClient.Parameters = .init(
                url: url,
                callbackUrlScheme: callbackScheme,
                presentationContextProvider: parameters.presentationContextProvider ?? WebAuthenticationSessionClient.DefaultPresentationProvider(),
                clientType: ClientType.consumer
            )
            #else
            let webClientParams: WebAuthenticationSessionClient.Parameters = .init(url: url, callbackUrlScheme: callbackScheme)
            #endif
            return try await webAuthSessionClient.initiate(parameters: webClientParams)
        }

        private func generateStartUrl(
            loginRedirectUrl: URL?,
            signupRedirectUrl: URL?,
            customScopes: [String]?
        ) throws -> URL {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }

            var queryParameters = [
                ("code_challenge", try StytchClient.generateAndStorePKCE(keychainItem: .codeVerifierPKCE).challenge),
                ("public_token", publicToken),
            ]

            [
                ("login_redirect_url", loginRedirectUrl?.absoluteString),
                ("signup_redirect_url", signupRedirectUrl?.absoluteString),
                ("custom_scopes", customScopes?.joined(separator: " ")),
            ].forEach { name, value in
                guard let value = value else { return }
                queryParameters.append((name, value))
            }

            let subDomain = publicToken.hasPrefix("public-token-test") ? "test" : "api"

            guard
                let url = URL(string: "https://\(subDomain).stytch.com/v1/public/oauth/\(provider.rawValue)/start")?.appending(queryParameters: queryParameters)
            else { throw StytchError.oauthInvalidStartUrl }

            return url
        }

        /// The dedicated parameters type for the ``start(parameters:)-239i4`` call.
        public struct DefaultBrowserStartParameters {
            let loginRedirectUrl: URL?
            let signupRedirectUrl: URL?
            let customScopes: [String]?

            /// - Parameters:
            ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This should be a url that redirects back to your app. If this value is not passed, the default login redirect URL set in the Stytch Dashboard is used. If you have not set a default login redirect URL, an error is returned.
            ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This should be a url that redirects back to your app. If this value is not passed, the default sign-up redirect URL set in the Stytch Dashboard is used. If you have not set a default sign-up redirect URL, an error is returned.
            ///   - customScopes: Any additional scopes to be requested from the identity provider.
            public init(
                loginRedirectUrl: URL? = nil,
                signupRedirectUrl: URL? = nil,
                customScopes: [String]? = nil
            ) {
                self.loginRedirectUrl = loginRedirectUrl
                self.signupRedirectUrl = signupRedirectUrl
                self.customScopes = customScopes
            }
        }

        /// The dedicated parameters type for the ``start(parameters:)-p3l8`` call.
        @available(tvOS 16.0, *)
        public struct WebAuthSessionStartParameters {
            let loginRedirectUrl: URL
            let signupRedirectUrl: URL
            let customScopes: [String]?
            #if !os(tvOS)
            let presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

            /// - Parameters:
            ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
            ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
            ///   - customScopes: Any additional scopes to be requested from the identity provider.
            ///   - presentationContextProvider: You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
            public init(
                loginRedirectUrl: URL,
                signupRedirectUrl: URL,
                customScopes: [String]? = nil,
                presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
            ) {
                self.loginRedirectUrl = loginRedirectUrl
                self.signupRedirectUrl = signupRedirectUrl
                self.customScopes = customScopes
                self.presentationContextProvider = presentationContextProvider
            }
            #else
            /// - Parameters:
            ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
            ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
            ///   - customScopes: Any additional scopes to be requested from the identity provider.
            ///   - presentationContextProvider: You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
            public init(
                loginRedirectUrl: URL,
                signupRedirectUrl: URL,
                customScopes: [String]? = nil
            ) {
                self.loginRedirectUrl = loginRedirectUrl
                self.signupRedirectUrl = signupRedirectUrl
                self.customScopes = customScopes
            }
            #endif
        }
    }
}

extension StytchClient.OAuth.ThirdParty {
    enum Provider: String, CaseIterable {
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
    }
}
#endif
