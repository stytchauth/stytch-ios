import Foundation

final class NetworkingClient {
    var headerProvider: (() -> [String: String])?

    private let session = URLSession(configuration: .default)

    func performRequest(_ method: Method, url: URL) async throws -> (Data, URLResponse) {
        let request = urlRequest(url: url, method: method)
        return try await session.data(for: request)
    }

    private func urlRequest(url: URL, method: Method) -> URLRequest {
        var request: URLRequest = .init(url: url)

        request.httpMethod = method.stringValue

        headerProvider?().forEach { field, value in
            request.addValue(value, forHTTPHeaderField: field)
        }

        switch method {
        case .get, .delete:
            break
        case let .post(data), let .put(data):
            request.httpBody = data
        }

        return request
    }
}
