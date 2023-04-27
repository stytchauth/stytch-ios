// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.MagicLinks {
    /// The Authenticate Discovery Magic Link method wraps the [authenticate](https://stytch.com/docs/b2b/api/send-discovery-email) discovery magic link API endpoint, which validates the discovery magic link token passed in.
    func discoveryAuthenticate(parameters: DiscoveryAuthenticateParameters, completion: @escaping Completion<DiscoveryAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await discoveryAuthenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// The Authenticate Discovery Magic Link method wraps the [authenticate](https://stytch.com/docs/b2b/api/send-discovery-email) discovery magic link API endpoint, which validates the discovery magic link token passed in.
    func discoveryAuthenticate(parameters: DiscoveryAuthenticateParameters) -> AnyPublisher<DiscoveryAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await discoveryAuthenticate(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
