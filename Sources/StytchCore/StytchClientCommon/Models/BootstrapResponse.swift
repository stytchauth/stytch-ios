/// The concrete response type for `bootstrap` calls.
public typealias BootstrapResponse = Response<BootstrapResponseData>

/// Represents the interface of responses for `bootstrap` calls.
public typealias BootstrapResponseType = BasicResponseType & BootstrapResponseDataType

/// The interface which a data type must conform to for all underlying data in `bootstrap` responses.
public protocol BootstrapResponseDataType {
    var disableSdkWatermark: Bool { get }
    var cnameDomain: String? { get }
    var emailDomains: [String] { get }
    var captchaSettings: CaptchaSettings { get }
    var pkceRequiredForEmailMagicLinks: Bool { get }
    var pkceRequiredForPasswordResets: Bool { get }
    var pkceRequiredForOauth: Bool { get }
    var pkceRequiredForSso: Bool { get }
    var slugPattern: String? { get }
    var createOrganizationEnabled: Bool { get }
    var dfpProtectedAuthEnabled: Bool { get }
}

/// The underlying data for `bootstrap` calls.
public struct BootstrapResponseData: Codable, BootstrapResponseDataType {
    public let disableSdkWatermark: Bool
    public let cnameDomain: String?
    public let emailDomains: [String]
    public let captchaSettings: CaptchaSettings
    public let pkceRequiredForEmailMagicLinks: Bool
    public let pkceRequiredForPasswordResets: Bool
    public let pkceRequiredForOauth: Bool
    public let pkceRequiredForSso: Bool
    public let slugPattern: String?
    public let createOrganizationEnabled: Bool
    public let dfpProtectedAuthEnabled: Bool
}

public struct CaptchaSettings: Codable {
    public let enabled: Bool
    public let siteKey: String?
}
