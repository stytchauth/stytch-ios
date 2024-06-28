// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations.Members {
    /// Deletes a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
    func delete(memberId: String, completion: @escaping Completion<OrganizationMemberDeleteResponse>) {
        Task {
            do {
                completion(.success(try await delete(memberId: memberId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Deletes a Member. The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
    func delete(memberId: String) -> AnyPublisher<OrganizationMemberDeleteResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await delete(memberId: memberId)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
