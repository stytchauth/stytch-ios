import Foundation
import Networking

extension StytchClient {
    static func post<Parameters: Encodable, Response: Decodable>(
        parameters: Parameters,
        path: Path,
        queryItems: [URLQueryItem] = [],
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = instance.configuration else {
            completion(.failure(StytchError.clientNotConfigured))
            return
        }
        do {
            let data = try Current.jsonEncoder.encode(parameters)
            StytchClient.performRequest(
                .post(data),
                url: configuration.baseURL.appendingPathComponent(path).appendingQueryItems(queryItems),
                configuration: configuration,
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }

    static func get<Response: Decodable>(
        queryItems: [URLQueryItem],
        path: String,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = instance.configuration else {
            completion(.failure(StytchError.clientNotConfigured))
            return
        }
        guard var urlComponents = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            completion(.failure(StytchError(message: "Internal Error: Please alert Stytch engineer.")))
            return
        }
        var urlQueryItems = urlComponents.queryItems ?? []
        urlQueryItems.append(contentsOf: queryItems)
        urlComponents.queryItems = urlQueryItems
        guard let url = urlComponents.url else {
            completion(.failure(StytchError(message: "Internal Error: Please alert Stytch engineer.")))
            return
        }

        performRequest(.get, url: url, configuration: configuration, completion: completion)
    }

    private static func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method = .get,
        url: URL,
        configuration _: Configuration, // To be used by session tracking
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        Current.networkingClient.performRequest(method, url: url) { result in
            completion(
                result.flatMap { data, response in
                    do {
                        try response.verifyStatus(data: data)
                        let dataContainer = try Current.jsonDecoder.decode(DataContainer<Response>.self, from: data)
                        return .success(dataContainer.data)
                    } catch {
                        return .failure(error)
                    }
                }
            )
        }
    }
}

private extension HTTPURLResponse {
    func verifyStatus(data: Data) throws {
        switch statusCode {
        case 400..<500:
            throw StytchError(
                message: "Client error: Status code \(statusCode)",
                debugInfo: String(data: data, encoding: .utf8)
            )
        case 500..<600:
            throw StytchError(
                message: "Server error: Status code \(statusCode)",
                debugInfo: String(data: data, encoding: .utf8)
            )
        default:
            break
        }
    }
}

struct DataContainer<T: Decodable>: Decodable {
    var data: T
}

#if DEBUG
    extension DataContainer: Encodable where T: Encodable {}
#endif
