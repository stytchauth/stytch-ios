// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    /// Start an SSO authentication flow.
    @available(tvOS 16.0, *)
    func start(parameters: StartParameters, completion: @escaping Completion<(token: String, url: URL)>) {
        Task {
            do {
                completion(.success(try await start(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Start an SSO authentication flow.
    @available(tvOS 16.0, *)
    func start(parameters: StartParameters) -> AnyPublisher<(token: String, url: URL), Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await start(parameters: parameters)))
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
