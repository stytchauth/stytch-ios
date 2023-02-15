// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OAuth.Apple {
    /// Initiates the OAuth flow by using the included parameters to start a Sign In With Apple request. If the authentication is successful this method will return a new session object.
    func start(parameters: StartParameters, completion: @escaping Completion<AuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await start(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Initiates the OAuth flow by using the included parameters to start a Sign In With Apple request. If the authentication is successful this method will return a new session object.
    func start(parameters: StartParameters) -> AnyPublisher<AuthenticateResponse, Error> {
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
