// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations {
    /// Updates the current organization.
    func update(updateParameters: UpdateParameters, completion: @escaping Completion<OrganizationResponse>) {
        Task {
            do {
                completion(.success(try await update(updateParameters: updateParameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates the current organization.
    func update(updateParameters: UpdateParameters) -> AnyPublisher<OrganizationResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await update(updateParameters: updateParameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
