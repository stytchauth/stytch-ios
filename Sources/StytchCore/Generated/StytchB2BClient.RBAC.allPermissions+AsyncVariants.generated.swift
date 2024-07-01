// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.RBAC {
    /// Evaluates all permissions granted to the logged-in member.
    /// Returns a Map<RoleId, Map<Action, Boolean>> response indicating the member's permissions.
    /// Each boolean will be `true` if the member can perform the action, `false` otherwise.
    /// 
    /// If the member is not logged in, all values will be false.
    /// 
    /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
    func allPermissions(completion: @escaping Completion<[String: [String: Bool]]>) {
        Task {
            do {
                completion(.success(try await allPermissions()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Evaluates all permissions granted to the logged-in member.
    /// Returns a Map<RoleId, Map<Action, Boolean>> response indicating the member's permissions.
    /// Each boolean will be `true` if the member can perform the action, `false` otherwise.
    /// 
    /// If the member is not logged in, all values will be false.
    /// 
    /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
    func allPermissions() -> AnyPublisher<[String: [String: Bool]], Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await allPermissions()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
