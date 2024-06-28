// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Organizations {
    /// Search for Members from the caller's organization. Submitting an empty query returns all non-deleted Members.
    /// All fuzzy search filters require a minimum of three characters.
    /// The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
    func searchMembers(parameters: SearchParameters, completion: @escaping Completion<SearchMembersResponse>) {
        Task {
            do {
                completion(.success(try await searchMembers(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Search for Members from the caller's organization. Submitting an empty query returns all non-deleted Members.
    /// All fuzzy search filters require a minimum of three characters.
    /// The caller must have permission to call this endpoint via the project's RBAC policy & their role assignments.
    func searchMembers(parameters: SearchParameters) -> AnyPublisher<SearchMembersResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await searchMembers(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
