import Foundation

extension URL {
    /// Filters the queryParameters to remove any tuple pairs with a nil secondary value.
    /// Turning it from an array of [(String, String?)] to an array of [(String, String)].
    private func filteredQueryParameters(_ queryParameters: [(String, String?)]) -> [(String, String)] {
        var filteredQueryParameters = [(String, String)]()
        queryParameters.forEach { name, value in
            guard let value = value else {
                return
            }
            filteredQueryParameters.append((name, value))
        }
        return filteredQueryParameters
    }

    func appending(queryParameters: [(name: String, value: String?)]) -> URL {
        let filteredQueryParamters = filteredQueryParameters(queryParameters)
        guard filteredQueryParamters.isEmpty == false, var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(contentsOf: filteredQueryParamters.map(URLQueryItem.init(name:value:)))
        urlComponents.queryItems = queryItems
        return urlComponents.url ?? self
    }
}

extension Dictionary where Key == String, Value == String {
    func toURLParameters() -> String {
        let urlComponents = map { key, value in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "\(escapedKey)=\(escapedValue)"
        }
        return urlComponents.joined(separator: "&")
    }
}
