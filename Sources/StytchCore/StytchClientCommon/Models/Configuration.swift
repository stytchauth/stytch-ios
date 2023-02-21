import Foundation

struct Configuration {
    private enum CodingKeys: String, CodingKey { case hostUrl = "StytchHostURL", publicToken = "StytchPublicToken" }

    let publicToken: String

    let hostUrl: URL?

    var baseUrl: URL {
        #if DEBUG
        if let urlString = ProcessInfo.processInfo.environment["STYTCH_API_URL"], let url = URL(string: urlString) {
            return url
        }
        #endif
        var urlComponents: URLComponents = .init()
        urlComponents.scheme = "https"
        urlComponents.path = "/sdk/v1/"
        urlComponents.host = "web.stytch.com"
        guard let url = urlComponents.url else {
            fatalError("Error generating URL from URLComponents: \(urlComponents)")
        }
        return url
    }
}

extension Configuration: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        publicToken = try container.decode(key: .publicToken)
        do {
            hostUrl = try container.decode(key: .hostUrl)
        } catch {
            guard let urlString: String = try? container.decode(key: .hostUrl) else {
                hostUrl = nil
                return
            }
            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorruptedError(forKey: .hostUrl, in: container, debugDescription: "Not a valid URL")
            }
            hostUrl = url
        }
    }
}
