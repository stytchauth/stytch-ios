import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO.OIDC {
    struct OIDCConnection: Codable, Sendable {
        let organizationId: String
        let connectionId: String
        let status: String
        let displayName: String
        let redirectUrl: String
        let issuer: String
        let clientId: String
        let clientSecret: String
        let authorizationUrl: String
        let tokenUrl: String
        let userinfoUrl: String
        let jwksUrl: String
        let identityProvider: String

        /// - Parameters:
        ///   - organizationId: Globally unique UUID that identifies a specific Organization.
        ///   - connectionId: Globally unique UUID that identifies a specific OIDC Connection.
        ///   - status: The status of the connection. The possible values are `pending` or `active`. See the https://stytch.com/docs/b2b/api/update-oidc-connection Update OIDC Connection endpoint for more details.
        ///   - displayName: A human-readable display name for the connection.
        ///   - redirectUrl: The callback URL for this OIDC connection. This value will be passed to the IdP to redirect the Member back to Stytch after a sign-in attempt.
        ///   - issuer: A case-sensitive `https://` URL that uniquely identifies the IdP. This will be provided by the IdP.
        ///   - clientId: The OAuth2.0 client ID used to authenticate login attempts. This will be provided by the IdP.
        ///   - clientSecret: The secret belonging to the OAuth2.0 client used to authenticate login attempts. This will be provided by the IdP.
        ///   - authorizationUrl: The location of the URL that starts an OAuth login at the IdP. This will be provided by the IdP.
        ///   - tokenUrl: The location of the URL that issues OAuth2.0 access tokens and OIDC ID tokens. This will be provided by the IdP.
        ///   - userinfoUrl: The location of the IDP's UserInfo Endpoint. This will be provided by the IdP.
        ///   - jwksUrl: The location of the IdP's JSON Web Key Set, used to verify credentials issued by the IdP. This will be provided by the IdP.
        ///   - identityProvider: The identity provider of this connection. For OIDC, the accepted values are `generic`, `okta`, and `microsoft-entra`.
        init(
            organizationId: String,
            connectionId: String,
            status: String,
            displayName: String,
            redirectUrl: String,
            issuer: String,
            clientId: String,
            clientSecret: String,
            authorizationUrl: String,
            tokenUrl: String,
            userinfoUrl: String,
            jwksUrl: String,
            identityProvider: String
        ) {
            self.organizationId = organizationId
            self.connectionId = connectionId
            self.status = status
            self.displayName = displayName
            self.redirectUrl = redirectUrl
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
#endif
