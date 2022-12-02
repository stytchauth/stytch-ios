// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.UserManagement {
    /// Some docs
    func deleteFactor(_ factor: AuthenticationFactor, completion: @escaping Completion<UserResponse>) {
        Task {
            do {
                completion(.success(try await deleteFactor(factor)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Some docs
    func deleteFactor(_ factor: AuthenticationFactor) -> AnyPublisher<UserResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await deleteFactor(factor)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
