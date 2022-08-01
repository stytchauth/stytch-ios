// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.User {
    /// Some docs
    func delete(_ parameters: DeleteParameters, completion: @escaping Completion<UserResponse>) {
        Task {
            do {
                completion(.success(try await delete(parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Some docs
    func delete(_ parameters: DeleteParameters) -> AnyPublisher<UserResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await delete(parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
