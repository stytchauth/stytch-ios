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
    public let mfaRequired: MFARequired?
    /// Information about the primary authentication requirements of the Organization.
    public let primaryRequired: PrimaryRequired?
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
    var mfaRequired: MFARequired? { get }
    /// Information about the primary authentication requirements of the Organization.
    var primaryRequired: PrimaryRequired? { get }
}

/// The interface which a data type must conform to for all discovery flows that return a non optional intermediate session token
public protocol DiscoveryIntermediateSessionTokenDataType {
    /// The non optional intermediate session token returned by discovery flows separate from multi factor authentication
    var intermediateSessionToken: String { get }
}

public struct PrimaryRequired: Codable, Sendable {
    // Details the auth method that the member must also complete to fulfill the primary authentication requirements of the Organization.
    // For example, a value of [magic_link] indicates that the Member must also complete a magic link authentication step.
    // If you have an intermediate session token, you must pass it into that primary authentication step.
    var allowedAuthMethods: [String]
}

public struct MFARequired: Codable, Sendable {
    /// Information about the Member's options for completing MFA.
    public let memberOptions: MemberOptions?
    /// If null, indicates that no secondary authentication has been initiated.
    /// If equal to "sms_otp", indicates that the Member has a phone number, and a one time passcode has been sent to the Member's phone number.
    /// No secondary authentication will be initiated during calls to the discovery authenticate or list organizations endpoints, even if the Member has a phone number.
    public let secondaryAuthInitiated: String?
}

public struct MemberOptions: Codable, Sendable {
    /// The Member's MFA phone number.
    public let mfaPhoneNumber: String
    /// The Member's MFA TOTP registration ID.
    public let totpRegistrationId: String
}
