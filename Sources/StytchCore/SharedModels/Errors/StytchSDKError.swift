import Foundation

public struct StytchSDKErrorOptions {
    let errorType: String
    var url: URL?
}

/// Error class representing an error within the Stytch SDK.
public class StytchSDKError: StytchError {
    let errorType: String?
    let url: URL?

    init(message: String, options: StytchSDKErrorOptions? = nil) {
        url = options?.url
        errorType = options?.errorType
        super.init(name: "StytchSDKError", message: message)
    }
}

public extension StytchSDKError {
    static let uiEmlAndOtpInvalid = StytchUIInvalidConfiguration(message: "You cannot have both Email Magic Links and Email OTP configured at the same time.")
    static let consumerSDKNotConfigured = StytchSDKNotConfiguredError(clientName: "StytchClient")
    static let B2BSDKNotConfigured = StytchSDKNotConfiguredError(clientName: "StytchB2BClient")
    static let missingPKCE = StytchSDKError(
        message: "The PKCE code challenge or code verifier is missing. Make sure this flow is completed on the same device on which it was started.",
        options: .init(
            errorType: "missing_pkce"
        )
    )
    static let deeplinkUnknownTokenType = StytchDeeplinkError(
        message: "The deeplink received has an unknown token type.",
        options: .init(
            errorType: "deeplink_unknown_token_type"
        )
    )
    static let deeplinkMissingToken = StytchDeeplinkError(
        message: "The deeplink received has a missing token value.",
        options: .init(
            errorType: "deeplink_missing_token"
        )
    )
    static let noCurrentSession = StytchSDKError(
        message: "There is no session currently available. Make sure the user is authenticated with a valid session.",
        options: .init(
            errorType: "no_current_session"
        )
    )
    static let noBiometricRegistration = StytchSDKError(
        message: "There is no biometric registration available. Authenticate with another method and add a new biometric registration first.",
        options: .init(
            errorType: "no_biometric_registration"
        )
    )
    static let noBiometricRegistrationId = StytchSDKError(
        message: "There is no biometric registration ID on the device.",
        options: .init(
            errorType: "no_biometric_registration_id"
        )
    )
    static let biometricsAlreadyEnrolled = StytchSDKError(
        message: "There is already a biometric factor enrolled on this device. Fully authenticate with all factors and remove the existing registration before attempting to register again.",
        options: .init(
            errorType: "biometric_already_enrolled"
        )
    )
    static let invalidAuthorizationCredential = StytchSDKError(
        message: "The authorization credential is invalid. Verify that OAuth is set up correctly in the developer console, and call the start flow method.",
        options: .init(
            errorType: "invalid_authorization_credential"
        )
    )
    static let missingAuthorizationCredentialIDToken = StytchSDKError(
        message: "The authorization credential is missing an ID token.",
        options: .init(
            errorType: "missing_authorization_credential_id_token"
        )
    )
    static let passkeysUnsupported = StytchSDKError(
        message: "Passkeys are unsupported on this device.",
        options: .init(
            errorType: "passkeys_unsupported"
        )
    )
    static let randomNumberGenerationFailed = StytchSDKError(
        message: "System unable to generate a random data. Typically used for PKCE.",
        options: .init(
            errorType: "random_number_generation_failed"
        )
    )
    static let invalidStartURL = StytchSDKError(
        message: "The start URL was invalid or improperly formatted.",
        options: .init(
            errorType: "invalid_start_url"
        )
    )
    static let invalidRedirectScheme = StytchSDKError(
        message: "The scheme from the given redirect urls was invalid. Possible reasons include: nil scheme, non-custom scheme (using http or https), or differing schemes for login/signup urls.",
        options: .init(
            errorType: "invalid_redirect_scheme"
        )
    )
    static let missingURL = StytchSDKError(
        message: "The underlying web authentication service failed to return a URL.",
        options: .init(
            errorType: "missing_url"
        )
    )
    static let invalidCredentialType = StytchSDKError(
        message: "The public key credential type was not of the expected type.",
        options: .init(
            errorType: "invalid_credential_type"
        )
    )
    static let missingAttestationObject = StytchSDKError(
        message: "The public key credential is missing the attestation object.",
        options: .init(
            errorType: "missing_attestation_object"
        )
    )
    static let jsonDataNotConvertibleToString = StytchSDKError(
        message: "JSON data unable to be converted to String type.",
        options: .init(
            errorType: "json_data_not_convertible_to_string"
        )
    )
    static let startupClientNotConfiguredForClientType = StytchSDKError(
        message: "You must call `startupClient.start(clientType:)` before calling `startupClient.start()`.",
        options: .init(
            errorType: "missing_client_type"
        )
    )
    static let noOrganziationId = StytchSDKError(
        message: "No Organziation Id Configured",
        options: .init(
            errorType: "no_organziation_id"
        )
    )
    static let noMemberId = StytchSDKError(
        message: "No Member Id Configured",
        options: .init(
            errorType: "no_member_id"
        )
    )
    static let emailNotEligibleForJitProvioning = StytchSDKError(
        message: "Email Not Eligible For Jit Provioning",
        options: .init(
            errorType: "email_not_eligible_for_jit_provioning"
        )
    )
}

public class StytchSDKNotConfiguredError: StytchSDKError {
    let clientName: String

    init(clientName: String) {
        self.clientName = clientName
        super.init(
            message: "\(clientName) not yet configured. Must include a `StytchConfiguration.plist` in your main bundle or call `\(clientName).configure(publicToken:hostUrl:)` prior to other \(clientName) calls.",
            options: .init(
                errorType: "sdk_not_configured",
                url: .readmeUrl(withFragment: "configuration")
            )
        )
    }
}

public class StytchUIError: StytchSDKError {}

public class StytchUIInvalidConfiguration: StytchUIError {}

public class StytchDeeplinkError: StytchSDKError {}

private extension URL {
    static func readmeUrl(withFragment fragment: String) -> Self? {
        guard var urlComponents = URLComponents(string: "https://github.com/stytchauth/stytch-ios") else {
            return nil
        }
        urlComponents.fragment = fragment
        return urlComponents.url
    }
}
