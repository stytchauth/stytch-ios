/// The concrete response type for `authenticate` calls.
public typealias AuthenticateResponse = Response<AuthenticateResponseData>

/// The underlying data for `authenticate` calls.
public struct AuthenticateResponseData: Codable {
    /// The current user object.
    public let user: User
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    public let sessionToken: String
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    public let sessionJwt: String
    /// The ``Session`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    public let session: Session
}
