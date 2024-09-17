// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Gets all groups associated with an organization's SCIM connection.
    /// This method wraps the get-connection-groups endpoint (https://stytch.com/docs/b2b/api/get-scim-connection-groups).
    /// The caller must have permission to view SCIM via the project's RBAC policy & their role assignments.
    func getConnectionGroups(parameters: GetConnectionGroupsParameters, completion: @escaping Completion<SCIMGetConnectionGroupsResponse>) {
        Task {
            do {
                completion(.success(try await getConnectionGroups(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Gets all groups associated with an organization's SCIM connection.
    /// This method wraps the get-connection-groups endpoint (https://stytch.com/docs/b2b/api/get-scim-connection-groups).
    /// The caller must have permission to view SCIM via the project's RBAC policy & their role assignments.
    func getConnectionGroups(parameters: GetConnectionGroupsParameters) -> AnyPublisher<SCIMGetConnectionGroupsResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await getConnectionGroups(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
