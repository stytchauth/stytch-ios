// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    ///  Updates an existing SCIM connection.
    ///  This method wraps the update-connection endpoint (https://stytch.com/docs/b2b/api/update-scim-connection).
    ///  If attempting to modify the `scim_group_implicit_role_assignments` the caller must have the
    ///  `update.settings.implicit-roles` permission on the `stytch.organization` resource. For all other fields, the
    ///  caller must have the `update` permission on the `stytch.scim` resource. SCIM via the project's RBAC policy &
    ///  their role assignments.
    func updateConnection(parameters: UpdateConnectionParameters, completion: @escaping Completion<SCIMUpdateConnectionResponse>) {
        Task {
            do {
                completion(.success(try await updateConnection(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    ///  Updates an existing SCIM connection.
    ///  This method wraps the update-connection endpoint (https://stytch.com/docs/b2b/api/update-scim-connection).
    ///  If attempting to modify the `scim_group_implicit_role_assignments` the caller must have the
    ///  `update.settings.implicit-roles` permission on the `stytch.organization` resource. For all other fields, the
    ///  caller must have the `update` permission on the `stytch.scim` resource. SCIM via the project's RBAC policy &
    ///  their role assignments.
    func updateConnection(parameters: UpdateConnectionParameters) -> AnyPublisher<SCIMUpdateConnectionResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await updateConnection(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
