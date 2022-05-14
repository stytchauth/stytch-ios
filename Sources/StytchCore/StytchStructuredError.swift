import Foundation

public struct StytchStructuredError: Error, Decodable {
    public let statusCode: Int
    public let requestId: String
    public var type: ErrorType { errorType }
    private let errorType: ErrorType
    public var message: String { errorMessage }
    private let errorMessage: String
    public var url: URL { errorUrl }
    private let errorUrl: URL
}

public extension StytchStructuredError {
    enum DefinedErrorType: String {
        case unableToAuthMagicLink = "unable_to_auth_magic_link"
        case unableToAuthOtpCode = "unable_to_auth_otp_code"
        // TODO: - flesh out error type definitions
    }

    enum ErrorType: Decodable {
        case defined(DefinedErrorType)
        case undefined(rawValue: String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            if let underlying = DefinedErrorType(rawValue: rawValue) {
                self = .defined(underlying)
            } else {
                self = .undefined(rawValue: rawValue)
            }
        }
    }
}
