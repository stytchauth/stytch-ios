// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    func getConnections(completion: @escaping Completion<GetConnectionsResponse>) {
        Task {
            do {
                completion(.success(try await getConnections()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getConnections() -> AnyPublisher<GetConnectionsResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await getConnections()))
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
