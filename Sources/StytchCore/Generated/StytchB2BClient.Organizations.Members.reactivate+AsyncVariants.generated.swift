// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations.Members {
    /// Reactivates a deleted Member's status and its associated email status (if applicable) to active.
    /// The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments
    func reactivate(memberId: String, completion: @escaping Completion<OrganizationMemberResponse>) {
        Task {
            do {
                completion(.success(try await reactivate(memberId: memberId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Reactivates a deleted Member's status and its associated email status (if applicable) to active.
    /// The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments
    func reactivate(memberId: String) -> AnyPublisher<OrganizationMemberResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await reactivate(memberId: memberId)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
