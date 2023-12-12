import Foundation

/// Base class representing an error within the Stytch ecosystem.
public class StytchError: Error {
    var name: String
    var description: String
    var url: URL?
    
    init(
        name: String,
        description: String,
        url: URL? = nil
    ) {
        self.name = name
        self.description = description
        self.url = url
    }
}

/// Error class representing an error within the Stytch API.
public class StytchAPIError: StytchError, Decodable {
    let statusCode: Int
    let requestId: String?
    
    private enum CodingKeys: CodingKey {
        case name
        case description
        case url
        case statusCode
        case requestId
    }
    
    init(
        name: String,
        description: String,
        url: URL? = nil,
        statusCode: Int,
        requestId: String? = nil
    ) {
        self.statusCode = statusCode
        self.requestId = requestId
        super.init(name: name, description: description, url: url)
    }
        
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
        requestId = try? container.decode(String.self, forKey: .requestId)
        
        let name = try container.decode(String.self, forKey: .name)
        let description = try container.decode(String.self, forKey: .description)
        let url = try? container.decode(URL.self, forKey: .url)
        
        super.init(name: name, description: description, url: url)
    }
}

/// Error class representing when the Stytch SDK cannot reach the Stytch API.
public class StytchAPIUnreachableError: StytchError {
    init(description: String, url: URL? = nil) {
        super.init(name: "StytchAPIUnreachableError", description: description, url: url)
    }
}

/// Error class representing a schema error within the Stytch API.
public class StytchAPISchemaError: StytchError {
    init(description: String, url: URL? = nil) {
        super.init(name: "StytchAPISchemaError", description: description, url: url)
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
            description: "\(clientName) not yet configured. Must include a `StytchConfiguration.plist` in your main bundle or call `\(clientName).configure(publicToken:hostUrl:)` prior to other \(clientName) calls.",
            url: .readmeUrl(withFragment: "configuration")
        )
    }
}

public extension StytchSDKError {
    static let pckeNotAvailable = StytchSDKError(
        name: "pcke_not_available",
        description: "No PKCE code_verifier available. Redirect authentication must begin/end on this device."
    )
    static let randomNumberGenerationFailed = StytchSDKError(
        name: "random_number_generation_failed",
        description: "System unable to generate a random data. Typically used for PKCE."
    )
    static let unrecognizedDeeplinkTokenType = StytchSDKError(
        name: "unrecognized_deeplink_token_type",
        description: "Deeplink received with unrecognized `stytch_token_type`. Recognized values are `magic_links`, `oauth`, or `reset_password`"
    )
    static let missingDeeplinkToken = StytchSDKError(
        name: "missing_deeplink_token_type",
        description: "Deeplink received with no underlying `stytch_token` value."
    )
    static let noCurrentSession = StytchSDKError(
        name: "no_current_session",
        description: "There is no session currently available. Must authenticate prior to calling this method."
    )
    static let noBiometricRegistrationsAvailable = StytchSDKError(
        name: "no_biometric_registrations",
        description: "There are no biometric registrations available. Must authenticate with other methods and add a new biometric registration before calling this method."
    )
    static let oauthCredentialInvalid = StytchSDKError(
        name: "oauth_apple_credential_invalid",
        description: "The Sign In With Apple authorization credential was an invalid type/format."
    )
    static let oauthCredentialMissingIdToken = StytchSDKError(
        name: "oauth_apple_missing_id_token",
        description: "The Sign In With Apple authorization credential was missing an id_token."
    )
    static let oauthInvalidStartUrl = StytchSDKError(
        name: "oauth_generic_invalid_start_url",
        description: "The start url was invalid or improperly formatted."
    )
    static let oauthInvalidRedirectScheme = StytchSDKError(
        name: "oauth_generic_invalid_redirect_scheme",
        description: "The scheme from the given redirect urls was invalid. Possible reasons include: nil scheme, non-custom scheme (using http or https), or differing schemes for login/signup urls."
    )
    static let oauthASWebAuthMissingUrl = StytchSDKError(
        name: "oauth_generic_aswebauth_missing_url",
        description: "The underlying ASWebAuthenticationSession failed to return a URL"
    )
    
    static let passkeysInvalidPublicKeyCredentialType = StytchSDKError(
        name: "passkeys_invalid_credential_type",
        description: "The public key credential type was not of the expected type."
    )
    static let passkeysMissingAttestationObject = StytchSDKError(
        name: "passkeys_missing_attestation_object",
        description: "The public key credential is missing the attestation object."
    )
    static let jsonDataNotConvertibleToString = StytchSDKError(
        name: "json_data_not_convertible_to_string",
        description: "JSON data unable to be converted to String type."
    )
    static let passkeysNotSupported = StytchSDKError(
        name: "passkeys_not_supported",
        description: "Passkeys are unsupported on this device"
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
