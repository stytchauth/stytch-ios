import Foundation

public final class NetworkingClient {
    let session: URLSession = .init(configuration: .default)

    let dataTaskClient: DataTaskClient

    public var headerProvider: (() -> [String: String])?

    public init(dataTaskClient: DataTaskClient = .live) {
        self.dataTaskClient = dataTaskClient
    }

    @discardableResult
    public func performRequest(_ method: Method, url: URL, completion: @escaping Completion) -> TaskHandle {
        perform(
            request: urlRequest(url: url, method: method),
            completion: completion
        )
    }

    private func perform(request: URLRequest, completion: @escaping Completion) -> TaskHandle {
        dataTaskClient.handle(request: request, session: session, completion: completion)
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
//
//        print(request.curlString)

        return request
    }
}
//
//extension URLRequest {
//    var curlString: String {
//        guard let url = url else { return "" }
//        var baseCommand = #"curl "\#(url.absoluteString)""#
//
//        if httpMethod == "HEAD" {
//            baseCommand += " --head"
//        }
//
//        var command = [baseCommand]
//
//        if let method = httpMethod, method != "GET", method != "HEAD" {
//            command.append("-X \(method)")
//        }
//
//        if let headers = allHTTPHeaderFields {
//            for (key, value) in headers where key != "Cookie" {
//                command.append("-H '\(key): \(value)'")
//            }
//        }
//
//        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
//            command.append("-d '\(body)'")
//        }
//
//        return command.joined(separator: " \\\n\t")
//    }
//}

public extension NetworkingClient {
    typealias Completion = (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void

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

    enum Error: Swift.Error {
        case missingData
        case nonHttpResponse
    }

    // A handle wrapping the underlying DataTask which can easily be extended to pass through progress or cancellation functionality
    struct TaskHandle {
        weak var dataTask: URLSessionDataTask?

        public init(dataTask: URLSessionDataTask?) {
            self.dataTask = dataTask
        }
    }
}
