import Foundation
import Networking

// swiftlint:disable identifier_name
#if DEBUG
var Current: StytchClient.Environment = .init()
#else
let Current: StytchClient.Environment = .init()
#endif
// swiftlint:enable identifier_name

extension StytchClient {
    struct Environment {
        var clientInfo: ClientInfo = .init()

        var networkingClient: NetworkingClient = .live

        let sessionStorage: SessionStorage = .init()

        var jsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                do {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    formatter.formatOptions = [.withInternetDateTime]
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorrupted(
                        .init(codingPath: decoder.codingPath, debugDescription: "Expected date string to be ISO8601-formatted.")
                    )
                }
            }
            return decoder
        }()

        var jsonEncoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            return encoder
        }()

        var cookieClient: CookieClient = .live

        var keychainClient: KeychainClient = .live

        var date: () -> Date = Date.init
    }
}
