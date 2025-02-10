import Foundation

// swiftlint:disable type_contents_order

public struct StytchClientConfiguration: Equatable, Codable {
    private enum CodingKeys: String, CodingKey {
        case publicToken = "StytchPublicToken"
        case hostUrl = "StytchHostURL"
        case dfppaDomain = "StytchDfppaDomain"
    }

    public let publicToken: String
    public let hostUrl: URL?
    public let dfppaDomain: String

    /**
     Creates the configuration object to configure the `StytchClient` and `StytchB2BClient`, you must set the `publicToken`.
     - Parameters:
       - publicToken: Available via the Stytch dashboard in the `API keys` section
       - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which will be used as the domain for setting session-token cookies to be sent to your servers on subsequent requests. If not passed here, no cookies will be set on your behalf.
       - dfppaDomain: The domain that should be used for DFPPA
     */
    public init(publicToken: String, hostUrl: URL? = nil, dfppaDomain: String? = nil) {
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

public extension StytchClientConfiguration {
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
