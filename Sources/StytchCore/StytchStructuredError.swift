import Foundation

/// A structured error type, originating from Stytch's servers.
public struct StytchStructuredError: Error, Decodable {
    /// The HTTP status code associated with the error.
    public let statusCode: Int
    /// The id of the request.
    public let requestId: String
    /// The type of the error.
    public let errorType: ErrorType
    /// The message associated with the error.
    public var message: String { errorMessage }
    private let errorMessage: String
    /// The url at which further information about the error can be found.
    public var url: URL { errorUrl }
    private let errorUrl: URL
}

public extension StytchStructuredError {
    /// The type of the error.
    enum ErrorType: Decodable, Equatable {
        case endpointNotAuthorizedForSdk
        case unableToAuthMagicLink
        case unableToAuthOtpCode
        case unauthorizedCredentials
        case undefined(rawValue: String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self.errorType(for: rawValue)
        }

        private static func errorType(for value: String) -> Self {
            switch value {
            case "endpoint_not_authorized_for_sdk": return .endpointNotAuthorizedForSdk
            case "unable_to_auth_magic_link": return .unableToAuthMagicLink
            case "unable_to_auth_otp_code": return .unableToAuthOtpCode
            case "unauthorized_credentials": return .unauthorizedCredentials
            default: return .undefined(rawValue: value)
            }
        }
    }
}
