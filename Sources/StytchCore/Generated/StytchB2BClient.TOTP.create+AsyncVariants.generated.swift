// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.TOTP {
    /// Create a TOTP for a member
    func create(parameters: CreateParameters, completion: @escaping Completion<CreateResponse>) {
        Task {
            do {
                completion(.success(try await create(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Create a TOTP for a member
    func create(parameters: CreateParameters) -> AnyPublisher<CreateResponse, Error> {
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
