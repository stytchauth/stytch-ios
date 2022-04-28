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
