import Foundation

// swiftlint:disable type_contents_order

struct Configuration: Equatable {
    private enum CodingKeys: String, CodingKey {
        case publicToken = "StytchPublicToken"
        case hostUrl = "StytchHostURL"
        case dfppaDomain = "StytchDfppaDomain"
    }

    let publicToken: String
    let hostUrl: URL?
    let dfppaDomain: String

    internal init(publicToken: String, hostUrl: URL? = nil, dfppaDomain: String? = nil) {
        self.publicToken = publicToken
        self.hostUrl = hostUrl
        if let dfppaDomain {
            self.dfppaDomain = dfppaDomain
        } else {
            self.dfppaDomain = "telemetry.stytch.com"
        }
    }

    var baseUrl: URL {
        var urlComponents: URLComponents = .init()
        urlComponents.scheme = "https"
        urlComponents.path = "/sdk/v1/"

        if publicToken.hasPrefix("public-token-test") {
            urlComponents.host = "test.stytch.com"
        } else {
            urlComponents.host = "api.stytch.com"
        }

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
        dfppaDomain = try container.decode(key: .dfppaDomain)
        do {
            hostUrl = try container.decode(key: .hostUrl)
        } catch {
            guard let urlString: String = try? container.decode(key: .hostUrl) else {
                hostUrl = nil
                return
            }
            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorruptedError(forKey: .hostUrl, in: container, debugDescription: "Not a valid hostUrl URL")
            }
            hostUrl = url
        }
    }
}
