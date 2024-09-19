// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Cancels the SCIM bearer token rotate, removing the new bearer token issued.
    /// This method wraps the cancel-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-cancel).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func rotateCancel(parameters: RotateParameters, completion: @escaping Completion<SCIMRotateCancelResponse>) {
        Task {
            do {
                completion(.success(try await rotateCancel(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Cancels the SCIM bearer token rotate, removing the new bearer token issued.
    /// This method wraps the cancel-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-cancel).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func rotateCancel(parameters: RotateParameters) -> AnyPublisher<SCIMRotateCancelResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await rotateCancel(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
