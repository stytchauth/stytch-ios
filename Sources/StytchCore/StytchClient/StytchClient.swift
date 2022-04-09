import Foundation
import Networking

public final class StytchClient {
    static let instance: StytchClient = .init()

    let networkingClient: NetworkingClient

    var configuration: Configuration?

    let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // TODO: confirm decoding/encoding strategies
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private init(
        networkingClient: NetworkingClient = .init()
    ) {
        self.networkingClient = networkingClient
    }

    public static func configure(environment: Configuration.Environment = .production, publicToken: String) {
        instance.configuration = .init(environment: environment, publicToken: publicToken)
        instance.networkingClient.headerProvider = { [weak instance] in
            guard let configuration = instance?.configuration else { return [:] }
            return [
                "Authorization": "Bearer \(configuration.publicToken)",
            ]
        }
    }
}
