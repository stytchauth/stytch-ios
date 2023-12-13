import Foundation

/// Base class representing an error within the Stytch ecosystem.
public class StytchError: Error {
    public var name: String
    public var message: String
    public var url: URL?
    
    init(
        name: String,
        message: String,
        url: URL? = nil
    ) {
        self.name = name
        self.message = message
        self.url = url
    }
}

/// Error class representing an error within the Stytch API.
public class StytchAPIError: StytchError, Decodable {
    public let statusCode: Int
    public let requestId: String?
    
    private enum CodingKeys: CodingKey {
        case name
        case message
        case url
        case statusCode
        case requestId
    }
    
    init(
        name: String,
        message: String,
        url: URL? = nil,
        statusCode: Int,
        requestId: String? = nil
    ) {
        self.statusCode = statusCode
        self.requestId = requestId
        super.init(name: name, message: message, url: url)
    }
        
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
        requestId = try? container.decode(String.self, forKey: .requestId)
        
        let name = try container.decode(String.self, forKey: .name)
        let message = try container.decode(String.self, forKey: .message)
        let url = try? container.decode(URL.self, forKey: .url)
        
        super.init(name: name, message: message, url: url)
    }
}

/// Error class representing when the Stytch SDK cannot reach the Stytch API.
public class StytchAPIUnreachableError: StytchError {
    init(message: String, url: URL? = nil) {
        super.init(name: "StytchAPIUnreachableError", message: message, url: url)
    }
}

/// Error class representing a schema error within the Stytch API.
public class StytchAPISchemaError: StytchError {
    init(message: String, url: URL? = nil) {
        super.init(name: "StytchAPISchemaError", message: message, url: url)
    }
}

/// Error class representing an error within the Stytch SDK.
public class StytchSDKError: StytchError {}

/// Error class representing invalid input within the Stytch SDK.
public class StytchSDKUsageError: StytchError {}

public class StytchSDKNotConfiguredError: StytchSDKError {
    let clientName: String
    
    init(clientName: String) {
        self.clientName = clientName
        super.init(
            name: "sdk_not_configured",
            message: "\(clientName) not yet configured. Must include a `StytchConfiguration.plist` in your main bundle or call `\(clientName).configure(publicToken:hostUrl:)` prior to other \(clientName) calls.",
            url: .readmeUrl(withFragment: "configuration")
        )
    }
}

public class StytchDeeplinkError: StytchSDKError {}

public extension StytchSDKError {
    static let consumerSDKNotConfigured = StytchSDKNotConfiguredError(clientName: "StytchClient")
    static let B2BSDKNotConfigured = StytchSDKNotConfiguredError(clientName: "StytchB2BClient")
    static let missingPKCE = StytchSDKError(
        name: "missing_pkce",
        message: "The PKCE code challenge or code verifier is missing. Make sure this flow is completed on the same device on which it was started."
    )
    static let deeplinkUnknownTokenType = StytchDeeplinkError(
        name: "deeplink_unknown_token_type",
        message: "The deeplink received has an unknown token type."
    )
    static let deeplinkMissingToken = StytchDeeplinkError(
        name: "deeplink_missing_token",
        message: "The deeplink received has a missing token value."
    )
    static let noCurrentSession = StytchSDKError(
        name: "no_current_session",
        message: "There is no session currently available. Make sure the user is authenticated with a valid session."
    )
    static let noBiometricRegistration = StytchSDKError(
        name: "no_biometric_registration",
        message: "There is no biometric registration available. Authenticate with another method and add a new biometric registration first."
    )
    static let invalidAuthorizationCredential = StytchSDKError(
        name: "invalid_authorization_credential",
        message: "The authorization credential is invalid. Verify that OAuth is set up correctly in the developer console, and call the start flow method."
    )
    static let missingAuthorizationCredentialIDToken = StytchSDKError(
        name: "missing_authorization_credential_id_token",
        message: "The authorization credential is missing an ID token."
    )
    static let passkeysUnsupported = StytchSDKError(
        name: "passkeys_unsupported",
        message: "Passkeys are unsupported on this device"
    )
    static let randomNumberGenerationFailed = StytchSDKError(
        name: "random_number_generation_failed",
        message: "System unable to generate a random data. Typically used for PKCE."
    )
    static let invalidStartURL = StytchSDKError(
        name: "invalid_start_url",
        message: "The start URL was invalid or improperly formatted."
    )
    static let invalidRedirectScheme = StytchSDKError(
        name: "invalid_redirect_scheme",
        message: "The scheme from the given redirect urls was invalid. Possible reasons include: nil scheme, non-custom scheme (using http or https), or differing schemes for login/signup urls."
    )
    static let missingURL = StytchSDKError(
        name: "missing_url",
        message: "The underlying web authentication service failed to return a URL."
    )
    static let invalidPublicKeyCredentialType = StytchSDKError(
        name: "invalid_credential_type",
        message: "The public key credential type was not of the expected type."
    )
    static let missingAttestationObject = StytchSDKError(
        name: "missing_attestation_object",
        message: "The public key credential is missing the attestation object."
    )
    static let jsonDataNotConvertibleToString = StytchSDKError(
        name: "json_data_not_convertible_to_string",
        message: "JSON data unable to be converted to String type."
    )
}

private extension URL {
    static func readmeUrl(withFragment fragment: String) -> Self? {
        guard var urlComponents = URLComponents(string: "https://github.com/stytchauth/stytch-ios") else {
            return nil
        }
        urlComponents.fragment = fragment
        return urlComponents.url
    }
}
