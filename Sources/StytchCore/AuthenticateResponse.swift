/// The concrete response type for `authenticate` calls.
typealias AuthenticateResponse = Response<AuthenticateResponseData>

public typealias AuthenticateResponseType = BasicResponseType & AuthenticateResponseDataType

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
struct AuthenticateResponseData: Decodable, AuthenticateResponseDataType {
    /// The current user object.
    let user: User
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    let sessionToken: String
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    let sessionJwt: String
    /// The ``Session`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    let session: Session
}

#if DEBUG
extension AuthenticateResponseData: Encodable {}
#endif
