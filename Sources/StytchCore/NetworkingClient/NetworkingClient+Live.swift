import Foundation

var count = 0

extension NetworkingClient {
    static let live: NetworkingClient = {
        let session: URLSession = .init(configuration: .default)
        return .init { request, completion in
            if count > 1 {
                completion(.failure(Error.missingData))
                return .init(dataTask: nil)
            } else {
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let data = data else {
                        completion(.failure(Error.missingData))
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        completion(.failure(Error.nonHttpResponse))
                        return
                    }
                    completion(.success((data, response)))
                }
                task.resume()
                count += 1
                return .init(dataTask: task)
            }
        }
    }()
}
