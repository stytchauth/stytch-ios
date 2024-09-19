// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Deletes an existing SCIM connection.
    /// This method wraps the delete-connection endpoint (https://stytch.com/docs/b2b/api/delete-scim-connection).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func deleteConnection(connectionId: String, completion: @escaping Completion<SCIMDeleteConnectionResponse>) {
        Task {
            do {
                completion(.success(try await deleteConnection(connectionId: connectionId)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Deletes an existing SCIM connection.
    /// This method wraps the delete-connection endpoint (https://stytch.com/docs/b2b/api/delete-scim-connection).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func deleteConnection(connectionId: String) -> AnyPublisher<SCIMDeleteConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await deleteConnection(connectionId: connectionId)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
