// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    func discoverConnections(emailAddress: String, completion: @escaping Completion<DiscoverConnectionsResponse>) {
        Task {
            do {
                completion(.success(try await discoverConnections(emailAddress: emailAddress)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func discoverConnections(emailAddress: String) -> AnyPublisher<DiscoverConnectionsResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await discoverConnections(emailAddress: emailAddress)))
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
