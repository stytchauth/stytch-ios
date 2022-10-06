import Foundation

public extension StytchClient.OAuth {
    /// The SDK provides the ability to integrate with third-party identity providers for OAuth experiences beyond the natively-supported Sign In With Apple flow.
    struct ThirdParty {
        let provider: Provider

        /// Initiates the OAuth flow by using the included parameters to generate a URL and pass this off to the system's default browser. The user will be redirected to the corresponding redirectUrl (this should be back into the application), after completing the authentication challenge with the identity provider.
        public func start(parameters: StartParameters) throws {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }

            var queryParameters = [
                ("code_challenge", try StytchClient.generateAndStorePKCE(keychainItem: .oauthPKCECodeVerifier).challenge),
                ("public_token", publicToken),
            ]

            [
                ("login_redirect_url", parameters.loginRedirectUrl?.absoluteString),
                ("signup_redirect_url", parameters.signupRedirectUrl?.absoluteString),
                ("custom_scopes", parameters.customScopes?.joined(separator: " ")),
            ].forEach { name, value in
                guard let value = value else { return }
                queryParameters.append((name, value))
            }

            let subDomain = publicToken.hasPrefix("public-token-test") ? "test" : "api"

            guard
                let url = URL(string: "https://\(subDomain).stytch.com/v1/public/oauth/\(provider.rawValue)/start")?.appending(queryParameters: queryParameters)
            else { throw StytchError.oauthInvalidStartUrl }

            Current.openUrl(url)
        }

        /// The dedicated parameters type for the ``start(parameters:)`` call.
        public struct StartParameters: Encodable {
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
    }
}

extension StytchClient.OAuth.ThirdParty {
    enum Provider: String, CaseIterable {
        case amazon
        case bitbucket
        case coinbase
        case discord
        case facebook
        case github
        case gitlab
        case google
        case linkedin
        case microsoft
        case slack
        case twitch
    }
}
