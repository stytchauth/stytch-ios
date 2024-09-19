// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.SCIM {
    /// Starts the SCIM bearer token rotation process.
    /// This method wraps the start-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-start).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func rotateStart(parameters: RotateParameters, completion: @escaping Completion<SCIMRotateStartResponse>) {
        Task {
            do {
                completion(.success(try await rotateStart(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Starts the SCIM bearer token rotation process.
    /// This method wraps the start-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-start).
    /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
    func rotateStart(parameters: RotateParameters) -> AnyPublisher<SCIMRotateStartResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await rotateStart(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
