// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO.OIDC {
    func updateConnection(parameters: UpdateConnectionParameters, completion: @escaping Completion<OIDCConnectionResponse>) {
        Task {
            do {
                completion(.success(try await updateConnection(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func updateConnection(parameters: UpdateConnectionParameters) -> AnyPublisher<OIDCConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await updateConnection(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif
