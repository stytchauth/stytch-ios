// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Creates a new SCIM connection.
    /// This method wraps the create-connection endpoint (https://stytch.com/docs/b2b/api/create-scim-connection).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func createConnection(parameters: CreateConnectionParameters, completion: @escaping Completion<SCIMCreateConnectionResponse>) {
        Task {
            do {
                completion(.success(try await createConnection(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Creates a new SCIM connection.
    /// This method wraps the create-connection endpoint (https://stytch.com/docs/b2b/api/create-scim-connection).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func createConnection(parameters: CreateConnectionParameters) -> AnyPublisher<SCIMCreateConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await createConnection(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
