/// The concrete response type for `bootstrap` calls.
typealias BootstrapResponse = Response<BootstrapResponseData>

/// Represents the interface of responses for `bootstrap` calls.
typealias BootstrapResponseType = BasicResponseType & BootstrapResponseDataType

/// The interface which a data type must conform to for all underlying data in `bootstrap` responses.
protocol BootstrapResponseDataType {
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
    var dfpProtectedAuthMode: DFPProtectedAuthMode? { get }
    var rbacPolicy: RBACPolicy? { get }
    var passwordConfig: PasswordConfig? { get }
    var vertical: ClientType? { get }
    var clientType: ClientType? { get }
}

/// The underlying data for `bootstrap` calls.
public struct BootstrapResponseData: Codable, Sendable, BootstrapResponseDataType {
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
    public let dfpProtectedAuthMode: DFPProtectedAuthMode?
    public let rbacPolicy: RBACPolicy?
    public let passwordConfig: PasswordConfig?
    public let vertical: ClientType?

    public var clientType: ClientType? {
        vertical
    }
}

extension BootstrapResponseData {
    static var defaultBootstrapData: BootstrapResponseData {
        BootstrapResponseData(
            disableSdkWatermark: false,
            cnameDomain: nil,
            emailDomains: [],
            captchaSettings: .init(enabled: false, siteKey: nil),
            pkceRequiredForEmailMagicLinks: false,
            pkceRequiredForPasswordResets: false,
            pkceRequiredForOauth: false,
            pkceRequiredForSso: false,
            slugPattern: nil,
            createOrganizationEnabled: false,
            dfpProtectedAuthEnabled: false,
            dfpProtectedAuthMode: .observation,
            rbacPolicy: nil,
            passwordConfig: nil,
            vertical: nil
        )
    }
}

public struct PasswordConfig: Codable, Sendable {
    public let ludsComplexity: Int
    public let ludsMinimumCount: Int
}

public struct CaptchaSettings: Codable, Sendable {
    let enabled: Bool
    let siteKey: String?
}

public enum DFPProtectedAuthMode: String, Codable, Sendable {
    case observation = "OBSERVATION"
    case decisioning = "DECISIONING"
}
