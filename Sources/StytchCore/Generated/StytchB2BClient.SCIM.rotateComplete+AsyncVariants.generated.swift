// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Completes the SCIM bearer token rotate, removing the old bearer token from operation.
    /// This method wraps the complete-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-complete).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func rotateComplete(parameters: RotateParameters, completion: @escaping Completion<SCIMRotateCompleteResponse>) {
        Task {
            do {
                completion(.success(try await rotateComplete(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Completes the SCIM bearer token rotate, removing the old bearer token from operation.
    /// This method wraps the complete-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-complete).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func rotateComplete(parameters: RotateParameters) -> AnyPublisher<SCIMRotateCompleteResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await rotateComplete(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
