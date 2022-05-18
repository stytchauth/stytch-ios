/// The concrete response type for `authenticate` calls.
public typealias AuthenticateResponse = Response<AuthenticateResponseData>

/// The underlying data for `authenticate` calls. See ``SessionResponseType`` for more information.
public struct AuthenticateResponseData: Codable, SessionResponseType {
    private enum CodingKeys: String, CodingKey { case user = "__user", sessionToken, sessionJwt, session }

    /// The current user object.
    public let user: User?
    /// The opaque session token object repressenting the current session. This may be used by your server to validate the session's validity.
    public let sessionToken: String
    /// The session JWT repressenting the current session. This may be used by your server to validate the session's validity.
    public let sessionJwt: String
    /// The current session.
    public let session: Session
}
