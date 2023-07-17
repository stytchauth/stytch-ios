import AuthenticationServices
import Foundation

#if !os(watchOS)
public extension StytchB2BClient {
    /**
     * Single-Sign On (SSO) refers to the ability for a user to use a single identity to authenticate and gain access to
     * multiple apps and service. In the case of B2B, it generally refers for the ability to use a workplace identity
     * managed by their company. Read our [blog post](https://stytch.com/blog/single-sign-on-sso/) for more information
     * about SSO.
     *
     * Stytch supports the following SSO protocols:
     * - SAML
     */
    // sourcery: ExcludeWatchOS
    struct SSO {
        let router: NetworkingRouter<SSORoute>

        @Dependency(\.keychainClient) private var keychainClient

        @available(tvOS 16.0, *)
        private var webAuthSessionClient: WebAuthenticationSessionClient {
            Current.webAuthSessionClient
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Authenticate a member given a token. This endpoint verifies that the memeber completed the SSO Authentication flow by
        /// verifying that the token is valid and hasn't expired.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BAuthenticateResponse {
            guard let codeVerifier: String = try keychainClient.get(.codeVerifierPKCE) else {
                throw StytchError.pckeNotAvailable
            }

            return try await router.post(
                to: .authenticate,
                parameters: CodeVerifierParameters(codingPrefix: .pkce, codeVerifier: codeVerifier, wrapped: parameters)
            )
        }

        @available(tvOS 16.0, *) // Comments must be below attributes
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Start an SSO authentication flow.
        public func start(parameters: StartParameters) async throws -> (token: String, url: URL) {
            guard let callbackScheme = parameters.loginRedirectUrl.scheme, callbackScheme == parameters.signupRedirectUrl.scheme, !callbackScheme.hasPrefix("http") else {
                throw StytchError.oauthInvalidRedirectScheme
            }
            let url = try generateStartUrl(
                connectionId: parameters.connectionId,
                loginRedirectUrl: parameters.loginRedirectUrl,
                signupRedirectUrl: parameters.signupRedirectUrl
            )
            #if !os(tvOS)
            let webClientParams: WebAuthenticationSessionClient.Parameters = .init(
                url: url,
                callbackUrlScheme: callbackScheme,
                presentationContextProvider: parameters.presentationContextProvider ?? WebAuthenticationSessionClient.DefaultPresentationProvider(),
                clientType: ClientType.b2b
            )
            #else
            let webClientParams: WebAuthenticationSessionClient.Parameters = .init(url: url, callbackUrlScheme: callbackScheme)
            #endif
            return try await webAuthSessionClient.initiate(parameters: webClientParams)
        }

        private func generateStartUrl(
            connectionId: String,
            loginRedirectUrl: URL,
            signupRedirectUrl: URL
        ) throws -> URL {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }

            let queryParameters = [
                ("connection_id", connectionId),
                ("pkce_code_challenge", try StytchClient.generateAndStorePKCE(keychainItem: .codeVerifierPKCE).challenge),
                ("public_token", publicToken),
                ("login_redirect_url", loginRedirectUrl.absoluteString),
                ("signup_redirect_url", signupRedirectUrl.absoluteString),
            ]

            let subDomain = publicToken.hasPrefix("public-token-test") ? "test" : "api"

            guard
                let url = URL(string: "https://\(subDomain).stytch.com/v1/public/sso/start")?.appending(queryParameters: queryParameters)
            else { throw StytchError.oauthInvalidStartUrl }

            return url
        }
    }
}

public extension StytchB2BClient {
    /// The interface for interacting with SSO.
    static var sso: SSO { .init(router: router.scopedRouter { $0.sso }) }
}

public extension StytchB2BClient.SSO {
    /// A dedicated parameters type for SSO `authenticate` calls.
    struct AuthenticateParameters: Encodable {
        private enum CodingKeys: String, CodingKey {
            case token = "ssoToken"
            case sessionDuration = "sessionDurationMinutes"
        }

        let token: String
        let sessionDuration: Minutes

        /// - Parameters:
        ///   - token: The token to authenticate.
        ///   - sessionDuration: The duration, in minutes, for the requested session. Defaults to 30 minutes.
        public init(token: String, sessionDuration: Minutes = .defaultSessionDuration) {
            self.token = token
            self.sessionDuration = sessionDuration
        }
    }

    /// A dedicated parameters type for SSO `start` calls.
    struct StartParameters {
        let connectionId: String
        let loginRedirectUrl: URL
        let signupRedirectUrl: URL
        #if !os(tvOS)
        let presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

        /// - Parameters:
        ///   - connectionId: The ID of the SSO connection to use for the login flow.
        ///   - loginRedirectUrl: The url an existing member is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - signupRedirectUrl: The url a new member is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - presentationContextProvider: You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
        public init(
            connectionId: String,
            loginRedirectUrl: URL,
            signupRedirectUrl: URL,
            presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
        ) {
            self.connectionId = connectionId
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
            self.presentationContextProvider = presentationContextProvider
        }
        #else
        /// - Parameters:
        ///   - connectionId: The ID of the SSO connection to use for the login flow.
        ///   - loginRedirectUrl: The url an existing member is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - signupRedirectUrl: The url a new member is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        public init(
            connectionId: String,
            loginRedirectUrl: URL,
            signupRedirectUrl: URL
        ) {
            self.connectionId = connectionId
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
        }
        #endif
    }
}
#endif
