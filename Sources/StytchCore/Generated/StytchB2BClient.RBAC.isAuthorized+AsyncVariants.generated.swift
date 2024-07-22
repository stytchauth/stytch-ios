// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.RBAC {
    /// Determines whether the logged-in member is allowed to perform the specified action on the specified resource.
    /// Returns `true` if the member can perform the action, `false` otherwise.
    /// 
    /// If the member is not logged in, this method will always return false.
    /// If the resource or action provided are not valid for the configured RBAC policy, this method will return false.
    /// 
    /// To check authorization using cached data, use {@link isAuthorizedSync}.
    /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
    func isAuthorized(resourceId: String, action: String, completion: @escaping Completion<Bool>) {
        Task {
            do {
                completion(.success(try await isAuthorized(resourceId: resourceId, action: action)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Determines whether the logged-in member is allowed to perform the specified action on the specified resource.
    /// Returns `true` if the member can perform the action, `false` otherwise.
    /// 
    /// If the member is not logged in, this method will always return false.
    /// If the resource or action provided are not valid for the configured RBAC policy, this method will return false.
    /// 
    /// To check authorization using cached data, use {@link isAuthorizedSync}.
    /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
    func isAuthorized(resourceId: String, action: String) -> AnyPublisher<Bool, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await isAuthorized(resourceId: resourceId, action: action)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
