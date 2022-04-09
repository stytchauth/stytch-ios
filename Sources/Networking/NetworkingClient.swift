import Foundation

public final class NetworkingClient {
    let session: URLSession = .init(configuration: .default)

    public var headerProvider: (() -> [String: String])?

    public init() {}

    @discardableResult
    public func performRequest(_ method: Method, url: URL, completion: @escaping CompletionHandler) -> TaskHandle {
        return perform(
            request: urlRequest(url: url, method: method),// configuration: configuration),
            completion: completion
        )
    }

    private func perform(request: URLRequest, completion: @escaping CompletionHandler) -> TaskHandle {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(Error(message: "NetworkResult missing data and/or response")))
            }
        }
        task.resume()
        return TaskHandle(dataTask: task)
    }

    private func urlRequest(
        url: URL,
        method: Method
    ) -> URLRequest {
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

public extension NetworkingClient {
    typealias CompletionHandler = (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void

    struct Configuration {
        public var additionalHeaders: [String: String]

        public init(additionalHeaders: [String : String]) {
            self.additionalHeaders = additionalHeaders
        }
    }

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

    internal struct Error: Swift.Error {
        let message: String
    }

    struct TaskHandle {
        weak var dataTask: URLSessionDataTask?

        public var progress: Progress { dataTask?.progress ?? Progress(totalUnitCount: 0) }

        public func cancel() {
            dataTask?.cancel()
        }
    }
}

#if DEBUG
    public extension URLRequest {
        var curlString: String {
            guard let url = url else { return "" }
            var baseCommand = #"curl "\#(url.absoluteString)""#

            if httpMethod == "HEAD" {
                baseCommand += " --head"
            }

            var command = [baseCommand]

            if let method = httpMethod, method != "GET", method != "HEAD" {
                command.append("-X \(method)")
            }

            if let headers = allHTTPHeaderFields {
                for (key, value) in headers where key != "Cookie" {
                    command.append("-H '\(key): \(value)'")
                }
            }

            if let data = httpBody, let body = String(data: data, encoding: .utf8) {
                command.append("-d '\(body)'")
            }

            return command.joined(separator: " \\\n\t")
        }
    }
#endif
