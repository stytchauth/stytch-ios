// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.MagicLinks.Email {
    /// The Send Discovery Email method wraps the [send discovery email](https://stytch.com/docs/b2b/api/send-discovery-email) API endpoint.
    func discoverySend(parameters: DiscoveryParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await discoverySend(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// The Send Discovery Email method wraps the [send discovery email](https://stytch.com/docs/b2b/api/send-discovery-email) API endpoint.
    func discoverySend(parameters: DiscoveryParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await discoverySend(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
