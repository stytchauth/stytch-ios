import Foundation

extension StytchClient {
    static func post<Parameters: Encodable, Response: Decodable>(
        to endpoint: Endpoint,
        parameters: Parameters,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        Task {
            do {
                completion(.success(try await post(to: endpoint, parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    static func get<Response: Decodable>(
        endpoint: Endpoint,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        Task {
            do {
                completion(.success(try await get(endpoint: endpoint)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    static func post<Parameters: Encodable, Response: Decodable>(
        to endpoint: Endpoint,
        parameters: Parameters
    ) async throws -> Response {
        try await performRequest(.post(Current.jsonEncoder.encode(parameters)), endpoint: endpoint)
    }

    static func get<Response: Decodable>(endpoint: Endpoint) async throws -> Response {
        try await performRequest(.get, endpoint: endpoint)
    }

    private static func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method = .get,
        endpoint: Endpoint
    ) async throws -> Response {
        guard let configuration = instance.configuration else {
            throw StytchError.clientNotConfigured
        }

        let (data, response) = try await Current.networkingClient.performRequest(
            method,
            url: endpoint.url(baseUrl: configuration.baseUrl)
        )
        do {
            try response.verifyStatus(data: data)
            let dataContainer = try Current.jsonDecoder.decode(DataContainer<Response>.self, from: data)
            if let sessionResponse = dataContainer.data as? AuthenticateResponse {
                Current.sessionStorage.updateSession(
                    sessionResponse.session,
                    tokens: [
                        .jwt(sessionResponse.sessionJwt),
                        .opaque(sessionResponse.sessionToken),
                    ],
                    hostUrl: configuration.hostUrl
                )
            }
            return dataContainer.data
        } catch let error as StytchError where error.statusCode == 401 {
            Current.sessionStorage.reset()
            throw error
        } catch {
            throw error
        }
    }
}

private extension HTTPURLResponse {
    func verifyStatus(data: Data) throws {
        guard (400..<600).contains(statusCode) else { return }

        let error: Error

        do {
            error = try Current.jsonDecoder.decode(StytchError.self, from: data)
        } catch _ {
            var message = (500..<600).contains(statusCode) ?
                "Server networking error." :
                "Client networking error."

            String(data: data, encoding: .utf8).map { debugInfo in
                message.append(" Debug info: \(debugInfo)")
            }

            error = StytchError(
                statusCode: statusCode,
                errorType: "unknown_error",
                errorMessage: message
            )
        }

        throw error
    }
}

struct DataContainer<T: Decodable>: Decodable {
    var data: T
}

#if DEBUG
extension DataContainer: Encodable where T: Encodable {}
#endif
