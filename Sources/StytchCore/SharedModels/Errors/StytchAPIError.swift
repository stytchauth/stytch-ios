import Foundation

/// Error class representing an error within the Stytch API.
public class StytchAPIError: StytchError, Decodable {
    private enum CodingKeys: CodingKey {
        case statusCode
        case requestId
        case errorType
        case errorMessage
        case errorUrl
    }

    /// The HTTP status code associated with the error.
    public let statusCode: Int
    /// The id of the request.
    public let requestId: String?
    /// The type of the error.
    public let errorType: StytchAPIErrorType
    /// The message associated with the error.
    public let errorMessage: String
    /// The url at which further information about the error can be found. Nil if no additional information available.
    public var url: URL? { errorUrl }
    private let errorUrl: URL?

    init(
        statusCode: Int,
        requestId: String? = nil,
        errorType: StytchAPIErrorType,
        errorMessage: String,
        errorUrl: URL? = nil
    ) {
        self.statusCode = statusCode
        self.requestId = requestId
        self.errorType = errorType
        self.errorMessage = errorMessage
        self.errorUrl = errorUrl
        super.init(name: "StytchAPIError", message: errorMessage)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
        requestId = try container.decodeIfPresent(String.self, forKey: .requestId)
        errorType = try container.decode(StytchAPIErrorType.self, forKey: .errorType)
        errorMessage = try container.decode(String.self, forKey: .errorMessage)
        errorUrl = try? container.decodeIfPresent(URL.self, forKey: .errorUrl)
        super.init(name: "StytchAPIError", message: errorMessage)
    }
}
