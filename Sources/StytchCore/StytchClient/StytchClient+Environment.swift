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

        var networkingClient: NetworkingClient = .init(dataTaskClient: .live)

        let sessionStorage: Session.Storage = .init()

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

        var setCookie: (HTTPCookie) -> Void = HTTPCookieStorage.shared.setCookie(_:)

        var keychainRemove: (KeychainClient.Item) throws -> Void = KeychainClient.remove(_:)

        var keychainSet: (String, KeychainClient.Item) throws -> Void = { try KeychainClient.set($0, for: $1) }

        var keychainGet: (KeychainClient.Item) throws -> String? = KeychainClient.get(_:)

        var date: () -> Date = Date.init
    }
}
