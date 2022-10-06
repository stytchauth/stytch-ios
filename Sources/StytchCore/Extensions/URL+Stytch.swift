import Foundation

extension URL {
    func appending(queryParameters: [(name: String, value: String)]?) -> URL {
        guard
            let queryParameters = queryParameters,
            !queryParameters.isEmpty,
            var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { return self }

        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(contentsOf: queryParameters.map(URLQueryItem.init(name:value:)))

        urlComponents.queryItems = queryItems

        return urlComponents.url ?? self
    }
}
