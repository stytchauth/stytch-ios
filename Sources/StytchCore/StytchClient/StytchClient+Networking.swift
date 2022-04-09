import Foundation
import Networking

extension StytchClient {
    func post<Parameters: Encodable, Response: Decodable>(
        parameters: Parameters,
        path: String,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = configuration else {
            completion(.failure(StytchError(message: "StytchClient not yet configured. Call `StytchClient.configure(environment:publicToken:)` before any further StytchClient calls.")))
            return
        }
        do {
            let data = try StytchClient.instance.jsonEncoder.encode(parameters)
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
        guard var urlComponents = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL:  false) else {
            completion(.failure(StytchError(message: "Internal Error: Please alert Stytch engineer.")))
            return
        }
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(contentsOf: queryItems)
        urlComponents.queryItems = queryItems
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

        networkingClient.performRequest(
            method,
            url: url
        ) { [unowned self] result in
            // TODO: verify network response code code
            completion(
                result.flatMap { data, _ in
                    do {
                        return .success(try self.jsonDecoder.decode(Response.self, from: data))
                    } catch {
                        return .failure(error)
                    }
                }
            )
        }
    }
}

public struct StytchError: Error {
    let message: String
}
