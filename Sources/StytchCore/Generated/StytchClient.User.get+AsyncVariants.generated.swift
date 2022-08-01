// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.User {
    /// Some docs
    func get(completion: @escaping Completion<UserResponse>) {
        Task {
            do {
                completion(.success(try await get()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Some docs
    func get() -> AnyPublisher<UserResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await get()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
