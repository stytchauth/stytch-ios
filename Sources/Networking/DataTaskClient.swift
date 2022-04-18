import Foundation

public struct DataTaskClient {
    private let handleRequest: (URLRequest, URLSession, @escaping NetworkingClient.Completion) -> NetworkingClient.TaskHandle

    public init(
        handleRequest: @escaping (URLRequest, URLSession, @escaping NetworkingClient.Completion) -> NetworkingClient.TaskHandle
    ) {
        self.handleRequest = handleRequest
    }

    func handle(request: URLRequest, session: URLSession, completion: @escaping NetworkingClient.Completion) -> NetworkingClient.TaskHandle {
        handleRequest(request, session, completion)
    }
}

extension DataTaskClient {
    public static let live: Self = .init { request, session, completion in
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(NetworkingClient.Error(message: "NetworkResult missing data and/or response")))
            }
        }
        task.resume()
        return .init(dataTask: task)
    }

    // swiftlint:disable force_unwrapping
    public static func mock(returning result: Result<Data, Error>) -> DataTaskClient {
        .init { request, _, completion in
            completion(
                result.map { ($0, .init(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: request.allHTTPHeaderFields)!) }
            )
            return .init(dataTask: nil)
        }
    }
    // swiftlint:enable force_unwrapping
}
