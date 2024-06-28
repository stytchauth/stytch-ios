// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    func deleteConnection(connectionId: String, completion: @escaping Completion<DeleteConnectionResponse>) {
        Task {
            do {
                completion(.success(try await deleteConnection(connectionId: connectionId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteConnection(connectionId: String) -> AnyPublisher<DeleteConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await deleteConnection(connectionId: connectionId)))
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
