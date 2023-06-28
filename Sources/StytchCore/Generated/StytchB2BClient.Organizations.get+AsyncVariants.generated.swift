// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations {
    /// Fetches the most up-to-date version of the current organization.
    func get(completion: @escaping Completion<OrganizationResponse>) {
        Task {
            do {
                completion(.success(try await get()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches the most up-to-date version of the current organization.
    func get() -> AnyPublisher<OrganizationResponse, Error> {
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
