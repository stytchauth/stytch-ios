import Foundation

public extension DataTaskClient {
    static let live: Self = .init { request, session, completion in
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else {
                completion(.failure(NetworkingClient.Error.missingData))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkingClient.Error.nonHttpResponse))
                return
            }
            completion(.success((data, response)))
        }
        task.resume()
        return .init(dataTask: task)
    }
}
