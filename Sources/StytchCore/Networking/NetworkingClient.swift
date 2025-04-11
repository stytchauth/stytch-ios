import Foundation

final class NetworkingClient {
    typealias NetworkingClientRequestBlock = (URLRequest, Bool, DFPProtectedAuthMode, Bool) async throws -> (Data, HTTPURLResponse)

    var headerProvider: (() -> [String: String])?
    var dfpEnabled: Bool = false
    var dfpAuthMode = DFPProtectedAuthMode.observation

    private let handleRequest: NetworkingClientRequestBlock

    init(handleRequest: @escaping NetworkingClientRequestBlock) {
        self.handleRequest = handleRequest
    }

    func performRequest(_ method: Method, url: URL, useDFPPA: Bool) async throws -> (Data, HTTPURLResponse) {
        let request = urlRequest(url: url, method: method)
        return try await handleRequest(request, dfpEnabled, dfpAuthMode, useDFPPA)
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
