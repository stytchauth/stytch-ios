import Foundation

#if !os(watchOS)
public extension StytchClient.OAuth {
    /// The SDK provides the ability to integrate with third-party identity providers for OAuth experiences beyond the natively-supported Sign In With Apple flow.
    struct ThirdParty {
        let provider: Provider

        /// Initiates the OAuth flow by using the included parameters to generate a URL and pass this off to the system's default browser. The user will be redirected to the corresponding redirectUrl (this should be back into the application), after completing the authentication challenge with the identity provider.
        public func start(parameters: DefaultBrowserStartParameters) throws {
            let url = try generateStartUrl(
                loginRedirectUrl: parameters.loginRedirectUrl,
                signupRedirectUrl: parameters.signupRedirectUrl,
                customScopes: parameters.customScopes
            )

            Current.openUrl(url)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Docs
        public func start(parameters: WebAuthSessionStartParameters) async throws -> String {
            let callbackScheme = "stytch-authentication"
            let url = try generateStartUrl(
                loginRedirectUrl: webAuthenticationUrl(scheme: callbackScheme, path: parameters.loginRedirectPath),
                signupRedirectUrl: webAuthenticationUrl(scheme: callbackScheme, path: parameters.signupRedirectPath),
                customScopes: parameters.customScopes
            )
            return try await WebAuthenticationSessionClient.live.initiate(
                url: url,
                callbackUrlScheme: callbackScheme,
                presentationContextProvider: parameters.presentationContextProvider ?? WebAuthenticationSessionClient.DefaultPresentationProvider()
            )
        }

        private func generateStartUrl(
            loginRedirectUrl: URL?,
            signupRedirectUrl: URL?,
            customScopes: [String]?
        ) throws -> URL {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }

            var queryParameters = [
                ("code_challenge", try StytchClient.generateAndStorePKCE(keychainItem: .oauthPKCECodeVerifier).challenge),
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

        private func webAuthenticationUrl(scheme: String, path: String) throws -> URL {
            guard let url = URL(string: "\(scheme)://\(path.drop(while: { $0 == "/" }))") else {
                throw StytchError.oauthInvalidStartUrl // FIXME: -
            }
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

        /// The dedicated parameters type for the ``start(parameters:)-3cetj`` call.
        public struct WebAuthSessionStartParameters {
            let loginRedirectPath: String
            let signupRedirectPath: String
            let customScopes: [String]?
            let presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

            /// - Parameters:
            ///   - loginRedirectFIXME: The url an existing user is redirected to after authenticating with the identity provider. This should be a url that redirects back to your app. If this value is not passed, the default login redirect URL set in the Stytch Dashboard is used. If you have not set a default login redirect URL, an error is returned.
            ///   - signupRedirectFIXME: The url a new user is redirected to after authenticating with the identity provider. This should be a url that redirects back to your app. If this value is not passed, the default sign-up redirect URL set in the Stytch Dashboard is used. If you have not set a default sign-up redirect URL, an error is returned.
            ///   - customScopes: Any additional scopes to be requested from the identity provider.
            ///   - presentationContextProvider: FIXME: -
            public init(
                loginRedirectPath: String,
                signupRedirectPath: String,
                customScopes: [String]? = nil,
                presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
            ) {
                self.loginRedirectPath = loginRedirectPath
                self.signupRedirectPath = signupRedirectPath
                self.customScopes = customScopes
                self.presentationContextProvider = presentationContextProvider
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
#endif

import AuthenticationServices

struct WebAuthenticationSessionClient {
    private let initiate: (URL, String, ASWebAuthenticationPresentationContextProviding) async throws -> String

    init(initiate: @escaping @MainActor (URL, String, ASWebAuthenticationPresentationContextProviding) async throws -> String) {
        self.initiate = initiate
    }

    /// Returns: token
    @MainActor 
    func initiate(
        url: URL,
        callbackUrlScheme: String,
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async throws -> String {
        try await initiate(url, callbackUrlScheme, presentationContextProvider)
    }
}

extension WebAuthenticationSessionClient {
    static var live: Self {
        .init { url, callbackUrlScheme, presentationContextProvider in
            try await withCheckedThrowingContinuation { continuation in
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackUrlScheme) { url, error in
                    guard let url = url else {
                        continuation.resume(throwing: StytchError.unrecognizedDeeplinkTokenType) // FIXME: asdf
                        return
                    }
                    do {
                        guard let token = try StytchClient.tokenValues(for: url)?.1 else {
                            continuation.resume(throwing: StytchError.unrecognizedDeeplinkTokenType) // FIXME: asdf
                            return
                        }
                        continuation.resume(returning: token)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                session.presentationContextProvider = presentationContextProvider
                session.start()
            }
        }
    }
}

extension WebAuthenticationSessionClient {
    final class DefaultPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        @MainActor
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            .init()
        }
    }
}
