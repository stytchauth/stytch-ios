import Foundation

public extension StytchClient.OAuth {
    /// docs
    struct ThirdPartyProvider {
        let provider: Provider

        /// docs
        public func start(parameters: StartParameters) throws {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.pckeNotAvailable } // TODO: fix error

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

        /// docs
        public struct StartParameters: Encodable {
            let loginRedirectUrl: URL?
            let signupRedirectUrl: URL?
            let customScopes: [String]?

            /// docs
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

extension StytchClient.OAuth.ThirdPartyProvider {
    enum Provider: String {
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
