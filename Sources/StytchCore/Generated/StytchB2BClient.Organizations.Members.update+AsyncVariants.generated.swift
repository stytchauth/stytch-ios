// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations.Members {
    /// Updates a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
    func update(parameters: UpdateParameters, completion: @escaping Completion<OrganizationMemberResponse>) {
        Task {
            do {
                completion(.success(try await update(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
    func update(parameters: UpdateParameters) -> AnyPublisher<OrganizationMemberResponse, Error> {
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
