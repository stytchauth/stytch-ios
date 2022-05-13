import Foundation

extension StytchClient {
    struct Configuration {
        let hostUrl: URL

        let publicToken: String

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
}
