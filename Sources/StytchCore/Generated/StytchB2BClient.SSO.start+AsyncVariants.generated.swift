// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    /// Start an SSO authentication flow.
    @available(tvOS 16.0, *)
    func start(configuration: WebAuthenticationConfiguration, completion: @escaping Completion<(token: String, url: URL)>) {
        Task {
            do {
                completion(.success(try await start(configuration: configuration)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Start an SSO authentication flow.
    @available(tvOS 16.0, *)
    func start(configuration: WebAuthenticationConfiguration) -> AnyPublisher<(token: String, url: URL), Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await start(configuration: configuration)))
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
