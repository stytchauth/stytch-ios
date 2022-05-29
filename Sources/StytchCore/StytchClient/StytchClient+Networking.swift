import Foundation

extension StytchClient {
    static func post<Parameters: Encodable, Response: Decodable>(
        to endpoint: Endpoint,
        parameters: Parameters,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        do {
            let data = try Current.jsonEncoder.encode(parameters)
            StytchClient.performRequest(.post(data), endpoint: endpoint, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    static func get<Response: Decodable>(
        endpoint: Endpoint,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        performRequest(.get, endpoint: endpoint, completion: completion)
    }

    private static func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method = .get,
        endpoint: Endpoint,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = instance.configuration else {
            completion(.failure(StytchError.clientNotConfigured))
            return
        }

        Current.networkingClient.performRequest(method, url: endpoint.url(baseUrl: configuration.baseUrl)) { result in
            completion(
                result.flatMap { data, response in
                    do {
                        try response.verifyStatus(data: data)
                        let dataContainer = try Current.jsonDecoder.decode(DataContainer<Response>.self, from: data)
                        if let sessionResponse = dataContainer.data as? SessionResponseType {
                            Current.sessionStorage.updateSession(
                                sessionResponse.session,
                                tokens: [
                                    .jwt(sessionResponse.sessionJwt),
                                    .opaque(sessionResponse.sessionToken),
                                ],
                                hostUrl: configuration.hostUrl
                            )
                        }
                        return .success(dataContainer.data)
                    } catch let error as StytchError where error.errorType == StytchError.typeUnauthorizedCredentials {
                        Current.sessionStorage.reset()
                        return .failure(error)
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

            let errorType: String

            switch statusCode {
            case 401:
                errorType = StytchError.typeUnauthorizedCredentials
            default:
                errorType = "unknown_error"
            }

            error = StytchError(
                statusCode: statusCode,
                errorType: errorType,
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
