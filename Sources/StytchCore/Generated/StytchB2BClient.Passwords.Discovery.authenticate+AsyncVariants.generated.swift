// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords.Discovery {
    /// Authenticate an email/password combination in the discovery flow.
    /// This authenticate flow is only valid for cross-org passwords use cases, and is not tied to a specific organization.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<StytchB2BClient.DiscoveryAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Authenticate an email/password combination in the discovery flow.
    /// This authenticate flow is only valid for cross-org passwords use cases, and is not tied to a specific organization.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<StytchB2BClient.DiscoveryAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await authenticate(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
