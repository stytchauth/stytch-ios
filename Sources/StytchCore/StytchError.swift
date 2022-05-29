import Foundation

/// A structured error type, typically originating from Stytch's servers.
public struct StytchError: Error {
    /// The HTTP status code associated with the error. Nil if error originated from the client.
    public let statusCode: Int?
    /// The id of the request. Nil if error originated from the client.
    public let requestId: String?
    /// The type of the error.
    public let errorType: ErrorType
    /// The message associated with the error.
    public var message: String { errorMessage }
    private let errorMessage: String
    /// The url at which further information about the error can be found. Nil if no additional information available.
    public var url: URL? { errorUrl }
    private let errorUrl: URL?

    init(
        statusCode: Int? = nil,
        requestId: String? = nil,
        errorType: StytchError.ErrorType,
        errorMessage: String,
        errorUrl: URL? = nil
    ) {
        self.statusCode = statusCode
        self.requestId = requestId
        self.errorType = errorType
        self.errorMessage = errorMessage
        self.errorUrl = errorUrl
    }
}

extension StytchError: Decodable {}

public extension StytchError {
    /// The type of the error.
    enum ErrorType: Decodable, Equatable {
        // Server-defined
        case endpointNotAuthorizedForSdk
        case unableToAuthMagicLink
        case unableToAuthOtpCode
        case unauthorizedCredentials
        case undefined(rawValue: String)

        // Client-only
        case clientNotConfigured
        case pckeNotAvailable
        case randomNumberGenerationFailed
        case unrecognizedDeeplinkTokenType

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self.errorType(for: rawValue)
        }

        private static func errorType(for value: String) -> Self {
            switch value {
            case "endpoint_not_authorized_for_sdk":
                return .endpointNotAuthorizedForSdk
            case "unable_to_auth_magic_link":
                return .unableToAuthMagicLink
            case "unable_to_auth_otp_code":
                return .unableToAuthOtpCode
            case "unauthorized_credentials":
                return .unauthorizedCredentials
            default:
                return .undefined(rawValue: value)
            }
        }
    }
}

extension StytchError {
    static let clientNotConfigured: Self = .init(
        errorType: .clientNotConfigured,
        errorMessage: "StytchClient not yet configured. Must include a `StytchConfiguration.plist` in your main bundle or call `StytchClient.configure(hostUrl:publicToken:)` prior to other StytchClient calls.",
        errorUrl: .readmeUrl(withFragment: "configuration")
    )
    static let pckeNotAvailable: Self = .init(
        errorType: .pckeNotAvailable,
        errorMessage: "No PKCE code_verifier available. Redirect authentication must begin/end on this device."
    )
    static let randomNumberGenerationFailed: Self = .init(
        errorType: .randomNumberGenerationFailed,
        errorMessage: "System unable to generate a random data. Typically used for PKCE."
    )
    static let unrecognizedDeeplinkTokenType: Self = .init(
        errorType: .unrecognizedDeeplinkTokenType,
        errorMessage: "Deeplink received with unrecognized `stytch_token_type`. Recognized values are `magic_links` or `oauth`"
    )
}

private extension URL {
    static func readmeUrl(withFragment fragment: String) -> Self? {
        guard var urlComponents = URLComponents(string: "https://github.com/stytchauth/stytch-swift") else {
            return nil
        }
        urlComponents.fragment = fragment
        return urlComponents.url
    }
}
