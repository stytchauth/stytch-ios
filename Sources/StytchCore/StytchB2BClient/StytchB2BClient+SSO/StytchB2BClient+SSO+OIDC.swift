import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    /// The interface for XYZ
    var oidc: OIDC {
        .init(router: router.scopedRouter { $0.oidc })
    }
}

public extension StytchB2BClient.SSO {
    // sourcery: ExcludeWatchOS
    struct OIDC {
        let router: NetworkingRouter<StytchB2BClient.SSORoute.OIDCRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func createConnection(parameters: CreateConnectionParameters) async throws -> OIDCConnectionResponse {
            try await router.post(to: .createConnection, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        public func updateConnection(parameters: UpdateConnectionParameters) async throws -> OIDCConnectionResponse {
            try await router.put(to: .updateConnection(connectionId: parameters.connectionId), parameters: parameters)
        }
    }
}

public extension StytchB2BClient.SSO.OIDC {
    struct CreateConnectionParameters: Codable {
        let displayName: String?
        let identityProvider: String?

        /// - Parameters:
        ///   - displayName: A human-readable display name for the connection.
        ///   - identityProvider: The identity provider of this connection. For OIDC, the accepted values are `generic`, `okta`, and `microsoft-entra`.
        public init(displayName: String?, identityProvider: String?) {
            self.displayName = displayName
            self.identityProvider = identityProvider
        }
    }
}

public extension StytchB2BClient.SSO.OIDC {
    struct UpdateConnectionParameters: Codable {
        let connectionId: String
        let displayName: String?
        let issuer: String?
        let clientId: String?
        let clientSecret: String?
        let authorizationUrl: String?
        let tokenUrl: String?
        let userinfoUrl: String?
        let jwksUrl: String?
        let identityProvider: String?

        /// - Parameters:
        ///   - connectionId: Globally unique UUID that identifies a specific OIDC Connection.
        ///   - displayName: A human-readable display name for the connection.
        ///   - issuer: A case-sensitive `https://` URL that uniquely identifies the IdP. This will be provided by the IdP.
        ///   - clientId: The OAuth2.0 client ID used to authenticate login attempts. This will be provided by the IdP.
        ///   - clientSecret: The secret belonging to the OAuth2.0 client used to authenticate login attempts. This will be provided by the IdP.
        ///   - authorizationUrl: The location of the URL that starts an OAuth login at the IdP. This will be provided by the IdP.
        ///   - tokenUrl: The location of the URL that issues OAuth2.0 access tokens and OIDC ID tokens. This will be provided by the IdP.
        ///   - userinfoUrl: The location of the IDP's UserInfo Endpoint. This will be provided by the IdP.
        ///   - jwksUrl: The location of the IdP's JSON Web Key Set, used to verify credentials issued by the IdP. This will be provided by the IdP.
        ///   - identityProvider: The identity provider of this connection. For OIDC, the accepted values are `generic`, `okta`, and `microsoft-entra`.
        public init(
            connectionId: String,
            displayName: String? = nil,
            issuer: String? = nil,
            clientId: String? = nil,
            clientSecret: String? = nil,
            authorizationUrl: String? = nil,
            tokenUrl: String? = nil,
            userinfoUrl: String? = nil,
            jwksUrl: String? = nil,
            identityProvider: String? = nil
        ) {
            self.connectionId = connectionId
            self.displayName = displayName
            self.issuer = issuer
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.authorizationUrl = authorizationUrl
            self.tokenUrl = tokenUrl
            self.userinfoUrl = userinfoUrl
            self.jwksUrl = jwksUrl
            self.identityProvider = identityProvider
        }
    }
}

public extension StytchB2BClient.SSO.OIDC {
    /// The response type for OIDC connection calls.
    typealias OIDCConnectionResponse = Response<OIDCConnectionResponseData>

    /// The underlying data for the OIDC connection type.
    struct OIDCConnectionResponseData: Codable {
        /// The OIDC Connection object affected by this API call.
        public let connection: OIDCConnection
    }
}
#endif
