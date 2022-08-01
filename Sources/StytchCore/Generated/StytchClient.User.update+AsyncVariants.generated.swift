// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.User {
    /// Some docs
    func update(_ parameters: UpdateParameters, completion: @escaping Completion<UserResponse>) {
        Task {
            do {
                completion(.success(try await update(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Some docs
    func update(_ parameters: UpdateParameters) -> AnyPublisher<UserResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await update(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
