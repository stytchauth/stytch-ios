// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.UserManagement {
    func update(parameters: UpdateParameters, completion: @escaping Completion<UserResponse>) {
        Task {
            do {
                completion(.success(try await update(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func update(parameters: UpdateParameters) -> AnyPublisher<UserResponse, Error> {
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
