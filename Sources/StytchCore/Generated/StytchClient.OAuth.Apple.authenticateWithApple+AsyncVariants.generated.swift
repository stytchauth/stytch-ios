// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OAuth.Apple {
    /// This function is intended for rare cases where you must authenticate with Apple only and collect the JWT.
    /// This function will not create a Stytch user.
    func authenticateWithApple(completion: @escaping Completion<String>) {
        Task {
            do {
                completion(.success(try await authenticateWithApple()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This function is intended for rare cases where you must authenticate with Apple only and collect the JWT.
    /// This function will not create a Stytch user.
    func authenticateWithApple() -> AnyPublisher<String, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await authenticateWithApple()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
