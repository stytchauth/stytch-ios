// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Discovery {
    /// Wraps Stytch's [create Organization via discovery](https://stytch.com/docs/b2b/api/create-organization-via-discovery) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
    func createOrganization(parameters: CreateOrganizationParameters, completion: @escaping Completion<CreateOrganizationResponse>) {
        Task {
            do {
                completion(.success(try await createOrganization(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [create Organization via discovery](https://stytch.com/docs/b2b/api/create-organization-via-discovery) endpoint. This operation consumes the `intermediate_session_token`. If this method succeeds, the Member will be logged in, and granted an active session.
    func createOrganization(parameters: CreateOrganizationParameters) -> AnyPublisher<CreateOrganizationResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await createOrganization(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
