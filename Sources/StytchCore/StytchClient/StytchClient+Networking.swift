import Foundation
import Networking

extension StytchClient {
    static func post<Parameters: Encodable, Response: Decodable>(
        to endpoint: Endpoint,
        parameters: Parameters,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = instance.configuration else {
            completion(.failure(StytchGenericError.clientNotConfigured))
            return
        }
        do {
            let data = try Current.jsonEncoder.encode(parameters)
            StytchClient.performRequest(
                .post(data),
                url: endpoint.url(baseUrl: configuration.baseUrl),
                configuration: configuration,
                completion: completion
            )
        } catch {
            completion(.failure(error))
        }
    }

    static func get<Response: Decodable>(
        endpoint: Endpoint,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        guard let configuration = instance.configuration else {
            completion(.failure(StytchGenericError.clientNotConfigured))
            return
        }

        performRequest(
            .get,
            url: endpoint.url(baseUrl: configuration.baseUrl),
            configuration: configuration,
            completion: completion
        )
    }

    private static func performRequest<Response: Decodable>(
        _ method: NetworkingClient.Method = .get,
        url: URL,
        configuration: Configuration,
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        Current.networkingClient.performRequest(method, url: url) { result in
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
            let error: Error
            do {
                error = try Current.jsonDecoder.decode(StytchStructuredError.self, from: data)
            } catch _ {
                error = StytchGenericError(
                    message: "Client networking error",
                    origin: .network(statusCode: statusCode),
                    debugInfo: String(data: data, encoding: .utf8)
                )
            }
            throw error
        case 500..<600:
            let error: Error
            do {
                error = try Current.jsonDecoder.decode(StytchStructuredError.self, from: data)
            } catch _ {
                error = StytchGenericError(
                    message: "Server networking error",
                    origin: .network(statusCode: statusCode),
                    debugInfo: String(data: data, encoding: .utf8)
                )
            }
            throw error
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
