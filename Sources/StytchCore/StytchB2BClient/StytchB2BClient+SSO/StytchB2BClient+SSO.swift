import AuthenticationServices
import Foundation

#if !os(watchOS)
public extension StytchB2BClient {
    /// The interface for interacting with SSO.
    static var sso: SSO {
        .init(router: router.scopedRouter { $0.sso })
    }
}

public extension StytchB2BClient {
    // swiftlint:disable:next orphaned_doc_comment
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

        @Dependency(\.pkcePairManager) private var pkcePairManager
        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Authenticate a member given a token. This endpoint verifies that the memeber completed the SSO Authentication flow by
        /// verifying that the token is valid and hasn't expired.
        public func authenticate(parameters: AuthenticateParameters) async throws -> B2BMFAAuthenticateResponse {
            defer {
                try? pkcePairManager.clearPKCECodePair()
            }

            guard let pkcePair: PKCECodePair = pkcePairManager.getPKCECodePair() else {
                throw StytchSDKError.missingPKCE
            }

            let intermediateSessionTokenParameters = IntermediateSessionTokenParameters(
                intermediateSessionToken: sessionManager.intermediateSessionToken,
                wrapped: CodeVerifierParameters(
                    codingPrefix: .pkce,
                    codeVerifier: pkcePair.codeVerifier,
                    wrapped: parameters
                )
            )

            let mfaAuthenticateResponse: B2BMFAAuthenticateResponse = try await router.post(
                to: .authenticate,
                parameters: intermediateSessionTokenParameters,
                useDFPPA: true
            )

            sessionManager.b2bLastAuthMethodUsed = .sso

            return mfaAuthenticateResponse
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func getConnections() async throws -> GetConnectionsResponse {
            try await router.get(route: .getConnections)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func discoverConnections(emailAddress: String) async throws -> DiscoverConnectionsResponse {
            try await router.get(
                route: .discoverConnections,
                queryItems: [URLQueryItem(name: "email_address", value: emailAddress)]
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func deleteConnection(connectionId: String) async throws -> DeleteConnectionResponse {
            try await router.delete(route: .deleteConnection(connectionId: connectionId))
        }

        @available(tvOS 16.0, *) // Comments must be below attributes
        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Start an SSO authentication flow.
        public func start(configuration: WebAuthenticationConfiguration) async throws -> (token: String, url: URL) {
            let parameters = try configuration.webAuthenticationSessionClientParameters(providerName: "")
            return try await Current.webAuthenticationSessionClient.initiate(parameters: parameters)
        }
    }
}

public extension StytchB2BClient.SSO {
    struct WebAuthenticationConfiguration: WebAuthenticationSessionClientConfiguration {
        let connectionId: String?
        let loginRedirectUrl: URL?
        let signupRedirectUrl: URL?
        public let clientType: ClientType = .b2b
        @Dependency(\.pkcePairManager) private var pkcePairManager

        #if !os(tvOS)
        /// You may need to pass in your own context provider to give the `ASWebAuthenticationSession` the proper window to present from.
        public var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
        #endif

        /// - Parameters:
        ///   - connectionId: The ID of the SSO connection to use for the login flow.
        ///   - loginRedirectUrl: The url an existing user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        ///   - signupRedirectUrl: The url a new user is redirected to after authenticating with the identity provider. This url **must** use a custom scheme and be added to your Stytch Dashboard.
        public init(
            connectionId: String? = nil,
            loginRedirectUrl: URL? = nil,
            signupRedirectUrl: URL? = nil
        ) {
            self.connectionId = connectionId
            self.loginRedirectUrl = loginRedirectUrl
            self.signupRedirectUrl = signupRedirectUrl
        }

        public func startUrl(_: String) throws -> URL {
            guard let publicToken = StytchB2BClient.stytchClientConfiguration?.publicToken else {
                throw StytchSDKError.B2BSDKNotConfigured
            }

            var queryParameters: [String: String] = [
                "pkce_code_challenge": try pkcePairManager.generateAndReturnPKCECodePair().codeChallenge,
                "public_token": publicToken,
            ]

            if let connectionId {
                queryParameters["connection_id"] = connectionId
            }

            if let loginRedirectUrl = loginRedirectUrl?.absoluteString {
                queryParameters["login_redirect_url"] = loginRedirectUrl
            }

            if let signupRedirectUrl = signupRedirectUrl?.absoluteString {
                queryParameters["signup_redirect_url"] = signupRedirectUrl
            }

            let domain = Current.localStorage.stytchDomain(publicToken)
            guard let url = URL(string: "https://\(domain)/v1/public/sso/start?\(queryParameters.toURLParameters())") else {
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

public extension StytchB2BClient.SSO {
    /// A dedicated parameters type for SSO `authenticate` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let ssoToken: String
        let sessionDurationMinutes: Minutes
        let locale: StytchLocale

        /// - Parameters:
        ///   - ssoToken: The token to authenticate.
        ///   - sessionDurationMinutes: The duration, in minutes, for the requested session. Defaults to 5 minutes.
        ///   - locale: The locale is used to determine which language to use in the email. Parameter is a https://www.w3.org/International/articles/language-tags/ IETF BCP 47 language tag, e.g. "en".
        ///     Currently supported languages are English ("en"), Spanish ("es"), and Brazilian Portuguese ("pt-br"); if no value is provided, the copy defaults to English.
        public init(ssoToken: String, sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration, locale: StytchLocale = .en) {
            self.ssoToken = ssoToken
            self.sessionDurationMinutes = sessionDurationMinutes
            self.locale = locale
        }
    }
}

public extension StytchB2BClient.SSO {
    typealias GetConnectionsResponse = Response<GetConnectionsResponseData>

    struct GetConnectionsResponseData: Codable, Sendable {
        /// The list of SAML Connections owned by this organization.
        public let samlConnections: [SAML.SAMLConnection]
        /// The list of OIDC Connections owned by this organization.
        public let oidcConnections: [OIDC.OIDCConnection]
    }
}

public extension StytchB2BClient.SSO {
    typealias DiscoverConnectionsResponse = Response<DiscoverConnectionsResponseData>

    struct DiscoverConnectionsResponseData: Codable, Sendable {
        public let connections: [StytchB2BClient.SSOActiveConnection]
    }
}

public extension StytchB2BClient.SSO {
    typealias DeleteConnectionResponse = Response<DeleteConnectionResponseData>

    struct DeleteConnectionResponseData: Codable, Sendable {
        /// The connection_id that was deleted as part of the delete request.
        public let connectionId: String
    }
}
#endif
