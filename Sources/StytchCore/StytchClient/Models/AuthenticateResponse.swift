/// The concrete response type for `authenticate` calls.
public typealias AuthenticateResponse = Response<AuthenticateResponseData>

/// Represents the interface of responses for `authenticate` calls.
public typealias AuthenticateResponseType = BasicResponseType & AuthenticateResponseDataType

/// The interface which a data type must conform to for all underlying data in `authenticate` responses.
public protocol AuthenticateResponseDataType {
    /// The current user object.
    var user: User { get }
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    var sessionToken: String { get }
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    var sessionJwt: String { get }
    /// The ``Session`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    var session: Session { get }
}

/// The underlying data for `authenticate` calls.
public struct AuthenticateResponseData: Codable, Sendable, AuthenticateResponseDataType {
    /// The current user object.
    public let user: User
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    public let sessionToken: String
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    public let sessionJwt: String
    /// The ``Session`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    public let session: Session
}
