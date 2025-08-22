import Foundation

/// The concrete response type for B2B `authenticate` calls.
public typealias B2BAuthenticateResponse = Response<B2BAuthenticateResponseData>

/// Represents the interface of responses for B2B `authenticate` calls.
public typealias B2BAuthenticateResponseType = BasicResponseType & B2BAuthenticateResponseDataType

/// The underlying data for B2B `authenticate` calls.
public struct B2BAuthenticateResponseData: Codable, Sendable, B2BAuthenticateResponseDataType {
    /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    public let memberSession: MemberSession
    /// The current member object.
    public let member: Member
    /// The current organization object.
    public let organization: Organization
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    public let sessionToken: String
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    public let sessionJwt: String
    /// If a valid telemetry_id was passed in the request and the Fingerprint Lookup API returned results, the member_device response field will contain information about the member's device attributes.
    public let memberDevice: DeviceHistory?
}

/// The interface which a data type must conform to for all underlying data in B2B `authenticate` responses.
public protocol B2BAuthenticateResponseDataType {
    /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    var memberSession: MemberSession { get }
    /// The current member object.
    var member: Member { get }
    /// The current organization object.
    var organization: Organization { get }
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    var sessionToken: String { get }
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    var sessionJwt: String { get }
    /// If a valid telemetry_id was passed in the request and the Fingerprint Lookup API returned results, the member_device response field will contain information about the member's device attributes.
    var memberDevice: DeviceHistory? { get }
}
