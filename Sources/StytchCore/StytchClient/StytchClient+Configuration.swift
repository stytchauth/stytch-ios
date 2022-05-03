import Foundation

extension StytchClient {
    struct Configuration {
        let appLinks: [URL]

        let publicToken: String

        var baseUrl: URL {
            var urlComponents: URLComponents = .init()
            urlComponents.scheme = "https"
            urlComponents.path = "/web/sdk/"
            urlComponents.host = "stytch.com"
            #if DEBUG
            if let host = ProcessInfo.processInfo.environment["STYTCH_API_HOST"] {
                urlComponents.host = host
            }
            #endif
            guard let url = urlComponents.url else {
                fatalError("Error generating URL from URLComponents: \(urlComponents)")
            }
            return url
        }
    }
}
