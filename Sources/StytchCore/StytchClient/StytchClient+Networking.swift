import Foundation
import Networking

extension StytchClient {
    func post<Parameters: Encodable, Response: Decodable>(
        parameters: Parameters,
        path: Path,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = configuration else {
            completion(.failure(StytchError(message: "StytchClient not yet configured. Call `StytchClient.configure(environment:publicToken:)` before any further StytchClient calls.")))
            return
        }
        do {
            let data = try Current.jsonEncoder.encode(parameters)
            StytchClient.instance.performRequest(
                .post(data),
                url: configuration.baseURL.appendingPathComponent(path),
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }

    func get<Response: Decodable>(
        queryItems: [URLQueryItem],
        path: String,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = configuration else {
            completion(.failure(StytchError(message: "StytchClient not yet configured.")))
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

        performRequest(.get, url: url, completion: completion)
    }

    private func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method = .get,
        url: URL,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        Current.networkingClient.performRequest(method, url: url ) { result in
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
