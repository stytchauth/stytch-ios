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
        var networkingClient: NetworkingClient = .init(dataTaskClient: .live)

        var jsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            // TODO: confirm decoding/encoding strategies
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()

        var jsonEncoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601
            return encoder
        }()
    }
}
