import Foundation

let configuration: Configuration = {
    do {
        let data = try JSONEncoder().encode(ProcessInfo.processInfo.environment)
        return try JSONDecoder().decode(Configuration.self, from: data)
    } catch {
        fatalError("Error deserializing config")
    }
}()

struct Configuration: Decodable {
    let appleAppId: String
    let hostUrl: URL
    let port: UInt16
    let stytchProjectId: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard
            case let urlString = try container.decode(String.self, forKey: .hostUrl),
            let url = URL(string: urlString)
        else {
            throw DecodingError.dataCorruptedError(forKey: .hostUrl, in: container, debugDescription: "Expected valid URL string")
        }
        guard
            case let portString = try container.decode(String.self, forKey: .port),
            let _port = UInt16(portString)
        else {
            throw DecodingError.dataCorruptedError(forKey: .port, in: container, debugDescription: "Expected valid port string")
        }

        appleAppId = try container.decode(String.self, forKey: .appleAppId)
        hostUrl = url
        port = _port
        stytchProjectId = try container.decode(String.self, forKey: .stytchProjectId)
    }

    private enum CodingKeys: String, CodingKey {
        case appleAppId = "APPLE_APP_ID"
        case hostUrl = "HOST_URL"
        case port = "PORT"
        case stytchProjectId = "STYTCH_PROJECT_ID"
    }
}
