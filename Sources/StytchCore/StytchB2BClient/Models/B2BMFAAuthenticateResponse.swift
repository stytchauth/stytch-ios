import Foundation

/// The concrete response type for B2B MFA `authenticate` calls.
public typealias B2BMFAAuthenticateResponse = Response<B2BMFAAuthenticateResponseData>

/// Represents the interface of responses for B2B MFA `authenticate` calls.
public typealias B2BMFAAuthenticateResponseType = BasicResponseType & B2BMFAAuthenticateResponseDataType

/// The underlying data for B2B MFA `authenticate` calls.
public struct B2BMFAAuthenticateResponseData: Codable, Sendable, B2BMFAAuthenticateResponseDataType {
    /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    public let memberSession: MemberSession?
    /// The current member's ID.
    public let memberId: Member.ID
    /// The current member object.
    public let member: Member
    /// The current organization object.
    public let organization: Organization
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    public let sessionToken: String
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    public let sessionJwt: String
    /// An optional intermediate session token to be returned if multi factor authentication is enabled
    public let intermediateSessionToken: String?
    /// Indicates whether the Member is fully authenticated. If false, the Member needs to complete an MFA step to log in to the Organization.
    public let memberAuthenticated: Bool
    /// Information about the MFA requirements of the Organization and the Member's options for fulfilling MFA.
    public let mfaRequired: StytchB2BClient.MFARequired?
    /// Information about the primary authentication requirements of the Organization.
    public let primaryRequired: StytchB2BClient.PrimaryRequired?
    /// If Protected Auth is enabled and returned fingerprinting results, the memberDevice response field will contain information about the member's device attributes.
    public let memberDevice: DeviceHistory?
}

/// The interface which a data type must conform to for all underlying data in B2B MFA `authenticate` responses.
public protocol B2BMFAAuthenticateResponseDataType {
    /// The ``MemberSession`` object, which includes information about the session's validity, expiry, factors associated with this session, and more.
    var memberSession: MemberSession? { get }
    /// The current member's ID.
    var memberId: Member.ID { get }
    /// The current member object.
    var member: Member { get }
    /// The current organization object.
    var organization: Organization { get }
    /// The opaque token for the session. Can be used by your server to verify the validity of your session by confirming with Stytch's servers on each request.
    var sessionToken: String { get }
    /// The JWT for the session. Can be used by your server to verify the validity of your session either by checking the data included in the JWT, or by verifying with Stytch's servers as needed.
    var sessionJwt: String { get }
    /// An optional intermediate session token to be returned if multi factor authentication is enabled
    var intermediateSessionToken: String? { get }
    /// Indicates whether the Member is fully authenticated. If false, the Member needs to complete an MFA step to log in to the Organization.
    var memberAuthenticated: Bool { get }
    /// Information about the MFA requirements of the Organization and the Member's options for fulfilling MFA.
    var mfaRequired: StytchB2BClient.MFARequired? { get }
    /// Information about the primary authentication requirements of the Organization.
    var primaryRequired: StytchB2BClient.PrimaryRequired? { get }
    /// If Protected Auth is enabled and returned fingerprinting results, the memberDevice response field will contain information about the member's device attributes.
    var memberDevice: DeviceHistory? { get }
}

/// The interface which a data type must conform to for all discovery flows that return a non optional intermediate session token
public protocol DiscoveryIntermediateSessionTokenDataType {
    /// The non optional intermediate session token returned by discovery flows separate from multi factor authentication
    var intermediateSessionToken: String { get }
}
