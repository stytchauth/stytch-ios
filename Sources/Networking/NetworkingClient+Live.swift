import Foundation

public extension NetworkingClient {
    static let live: NetworkingClient = {
        let session: URLSession = .init(configuration: .default)
        return .init { request, completion in
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
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
    }()
}
