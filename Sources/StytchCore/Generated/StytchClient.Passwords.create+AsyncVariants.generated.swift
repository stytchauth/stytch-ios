// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Passwords {
    /// Create a new user with a password and an authenticated session for the user if requested. If a user with this email already exists in the project, an error will be returned.
    /// 
    /// Existing passwordless users who wish to create a password need to go through the reset password flow.
    func create(parameters: PasswordParameters, completion: @escaping Completion<CreateResponse>) {
        Task {
            do {
                completion(.success(try await create(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Create a new user with a password and an authenticated session for the user if requested. If a user with this email already exists in the project, an error will be returned.
    /// 
    /// Existing passwordless users who wish to create a password need to go through the reset password flow.
    func create(parameters: PasswordParameters) -> AnyPublisher<CreateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await create(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
