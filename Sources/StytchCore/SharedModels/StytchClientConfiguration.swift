import Foundation

// swiftlint:disable type_contents_order

public struct StytchClientConfiguration: Equatable, Codable {
    private enum CodingKeys: String, CodingKey {
        case publicToken = "StytchPublicToken"
        case defaultSessionDuration
        case enableAutomaticSessionExtension
        case dfppaDomain = "StytchDfppaDomain"
        case testDomain = "StytchTestDomain"
        case liveDomain = "StytchLiveDomain"
    }

    public let publicToken: String
    public let defaultSessionDuration: Minutes
    public let enableAutomaticSessionExtension: Bool
    public let dfppaDomain: String?
    public let testDomain: String
    public let liveDomain: String

    /**
     Creates the configuration object to configure the `StytchClient` and `StytchB2BClient`, you must set the `publicToken`.
     - Parameters:
       - publicToken: Available via the Stytch dashboard in the `Project Overview->Project ID & API keys` section
       - defaultSessionDuration:  The default session length in minutes, must be less than or equal to the value set in the Stytch Dashboard (Frontend SDKs > Session duration).
         Applies to all authentication calls unless explicitly overridden, defaults to 5 minutes.
       - enableAutomaticSessionExtension: If true, the session heartbeat will attempt to extend the session duration instead of only checking the validity.
       - dfppaDomain: The domain that should be used for DFPPA
       - testDomain: The custom domain to use for Stytch API calls for test projects
       - liveDomain: The custom domain to use for Stytch API calls for live projects
     */
    public init(
        publicToken: String,
        defaultSessionDuration: Minutes = 5,
        enableAutomaticSessionExtension: Bool = false,
        dfppaDomain: String? = nil,
        testDomain: String = "test.stytch.com",
        liveDomain: String = "api.stytch.com"
    ) {
        self.publicToken = publicToken
        self.defaultSessionDuration = defaultSessionDuration
        self.enableAutomaticSessionExtension = enableAutomaticSessionExtension
        self.dfppaDomain = dfppaDomain
        self.testDomain = testDomain
        self.liveDomain = liveDomain
    }

    public var baseUrl: URL {
        var urlComponents: URLComponents = .init()
        urlComponents.scheme = "https"
        urlComponents.path = "/sdk/v1/"

        if publicToken.hasPrefix("public-token-test") {
            urlComponents.host = testDomain
        } else {
            urlComponents.host = liveDomain
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
        defaultSessionDuration = try container.decode(key: .defaultSessionDuration)
        enableAutomaticSessionExtension = try container.decode(key: .enableAutomaticSessionExtension)
        dfppaDomain = try container.decode(key: .dfppaDomain)
        testDomain = try container.decode(key: .testDomain)
        liveDomain = try container.decode(key: .liveDomain)
    }
}
