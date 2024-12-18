import Foundation

public struct OAuthProviderValues: Codable, Sendable {
    /// The access_token that you may use to access the User's data in the provider's API.
    public let accessToken: String
    /// The id_token returned by the OAuth provider. ID Tokens are JWTs that contain structured information about a user. The exact content of each ID Token varies from provider to provider.
    /// ID Tokens are returned from OAuth providers that conform to the OpenID Connect specification, which is based on OAuth.
    public let idToken: String?
    /// The refresh_token that you may use to obtain a new access_token for the User within the provider's API.
    public let refreshToken: String?
    /// The OAuth scopes included for a given provider. See each provider's section above to see which scopes are included by default and how to add custom scopes.
    public let scopes: [String]
    /// The timestamp when the Session expires. Values conform to the RFC 3339 standard and are expressed in UTC, e.g. 2021-12-29T12:33:09Z.
    public let expiresAt: Date
}
