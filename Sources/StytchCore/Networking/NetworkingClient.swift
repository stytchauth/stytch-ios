import Foundation

final class NetworkingClient {
    var headerProvider: (() -> [String: String])?

    var dfpEnabled: Bool = false

    var dfpAuthMode = DFPProtectedAuthMode.observation

    var publicToken: String = ""

    var dfppaDomain: String = ""

    private let handleRequest: (URLRequest, Bool, DFPProtectedAuthMode, String, String) async throws -> (Data, HTTPURLResponse)

    init(handleRequest: @escaping (URLRequest, Bool, DFPProtectedAuthMode, String, String) async throws -> (Data, HTTPURLResponse)) {
        self.handleRequest = handleRequest
    }

    func performRequest(_ method: Method, url: URL) async throws -> (Data, HTTPURLResponse) {
        try await handleRequest(urlRequest(url: url, method: method), dfpEnabled, dfpAuthMode, publicToken, dfppaDomain)
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

extension NetworkingClient {
    enum Method {
        case delete
        case get
        case post(Data?)
        case put(Data?)

        var stringValue: String {
            switch self {
            case .delete:
                return "DELETE"
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            }
        }
    }
}
