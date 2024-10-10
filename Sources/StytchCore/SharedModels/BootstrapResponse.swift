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
}

/// The underlying data for `bootstrap` calls.
struct BootstrapResponseData: Codable, BootstrapResponseDataType {
    let disableSdkWatermark: Bool
    let cnameDomain: String?
    let emailDomains: [String]
    let captchaSettings: CaptchaSettings
    let pkceRequiredForEmailMagicLinks: Bool
    let pkceRequiredForPasswordResets: Bool
    let pkceRequiredForOauth: Bool
    let pkceRequiredForSso: Bool
    let slugPattern: String?
    let createOrganizationEnabled: Bool
    let dfpProtectedAuthEnabled: Bool
    let dfpProtectedAuthMode: DFPProtectedAuthMode?
    let rbacPolicy: RBACPolicy?
    let passwordConfig: PasswordConfig?
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
            passwordConfig: nil
        )
    }
}

struct PasswordConfig: Codable {
    let ludsComplexity: Int
    let ludsMinimumCount: Int
}

struct CaptchaSettings: Codable {
    let enabled: Bool
    let siteKey: String?
}

enum DFPProtectedAuthMode: String, Codable {
    case observation = "OBSERVATION"
    case decisioning = "DECISIONING"
}
