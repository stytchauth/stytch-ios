// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations {
    /// Deletes the current organization. The current member must be an admin.
    func delete(completion: @escaping Completion<OrganizationDeleteResponse>) {
        Task {
            do {
                completion(.success(try await delete()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Deletes the current organization. The current member must be an admin.
    func delete() -> AnyPublisher<OrganizationDeleteResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await delete()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
