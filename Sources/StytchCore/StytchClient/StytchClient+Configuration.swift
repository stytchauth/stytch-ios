import Foundation

public extension StytchClient {
    struct Configuration {
        public let environment: Environment
        let publicToken: String

        var baseURL: URL {
            var urlComponents: URLComponents = .init()
            urlComponents.scheme = "https"
            urlComponents.path = "web/sdk"
            switch environment {
            case .test:
                urlComponents.host = "test.stytch.com"
            case .production:
                urlComponents.host = "stytch.com"
            }
            return urlComponents.url!
        }
    }
}

public extension StytchClient.Configuration {
    enum Environment {
        case test
        case production
    }
    struct NetworkConfiguration {
        public let basePath: String
    }
}
