// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Discovery {
    /// Wraps Stytch's [list discovered Organizations](https://stytch.com/docs/b2b/api/list-discovered-organizations) endpoint. If the `intermediate_session_token` is not passed in and there is a current Member Session, the SDK will call the endpoint with the session token.
    func listOrganizations(parameters: ListOrganizationsParameters, completion: @escaping Completion<ListOrganizationsResponse>) {
        Task {
            do {
                completion(.success(try await listOrganizations(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [list discovered Organizations](https://stytch.com/docs/b2b/api/list-discovered-organizations) endpoint. If the `intermediate_session_token` is not passed in and there is a current Member Session, the SDK will call the endpoint with the session token.
    func listOrganizations(parameters: ListOrganizationsParameters) -> AnyPublisher<ListOrganizationsResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await listOrganizations(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
