import Foundation

let configuration: Configuration = {
    do {
        let data = try JSONEncoder().encode(ProcessInfo.processInfo.environment)
        return try JSONDecoder().decode(Configuration.self, from: data)
    } catch {
        fatalError("ERROR generating config from Environment")
    }
}()

struct Configuration: Decodable {
    let hostUrl: URL
    let appId: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard
            case let urlString = try container.decode(String.self, forKey: .hostUrl),
            let url = URL(string: urlString)
        else {
            throw DecodingError
                .dataCorruptedError(forKey: .hostUrl, in: container, debugDescription: "Expected valid URL string")
        }

        hostUrl = url
        appId = try container.decode(String.self, forKey: .appId)
    }

    private enum CodingKeys: String, CodingKey {
        case appId = "APP_ID"
        case hostUrl = "HOST_URL"
    }
}
