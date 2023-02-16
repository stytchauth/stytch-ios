import Foundation

/// The concrete response type for B2B `authenticate` calls.
public typealias B2BAuthenticateResponse = Response<B2BAuthenticateResponseData>

public typealias B2BAuthenticateResponseType = BasicResponseType & B2BAuthenticateResponseDataType

public struct B2BAuthenticateResponseData: Codable, B2BAuthenticateResponseDataType {
    /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    public let memberSession: MemberSession
    /// The current member object.
    public let member: Member
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    public let sessionToken: String
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    public let sessionJwt: String
}

public protocol B2BAuthenticateResponseDataType {
    /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    var memberSession: MemberSession { get }
    /// The current member object.
    var member: Member { get }
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    var sessionToken: String { get }
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    var sessionJwt: String { get }
}
