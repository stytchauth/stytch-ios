// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.MagicLinks {
    /// Wraps the magic link [authenticate](https://stytch.com/docs/api/authenticate-magic-link) API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponseType>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps the magic link [authenticate](https://stytch.com/docs/api/authenticate-magic-link) API endpoint which validates the magic link token passed in. If this method succeeds, the user will be logged in, granted an active session, and the session cookies will be minted and stored in `HTTPCookieStorage.shared`.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<AuthenticateResponseType, Error> {
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
