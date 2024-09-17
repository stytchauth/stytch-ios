// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Gets the SCIM connection for an organization.
    /// This method wraps the get-connection endpoint (https://stytch.com/docs/b2b/api/get-scim-connection).
    /// The caller must have permission to view SCIM via the project's RBAC policy & their role assignments.
    func getConnection(completion: @escaping Completion<SCIMGetConnectionResponse>) {
        Task {
            do {
                completion(.success(try await getConnection()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Gets the SCIM connection for an organization.
    /// This method wraps the get-connection endpoint (https://stytch.com/docs/b2b/api/get-scim-connection).
    /// The caller must have permission to view SCIM via the project's RBAC policy & their role assignments.
    func getConnection() -> AnyPublisher<SCIMGetConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await getConnection()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
