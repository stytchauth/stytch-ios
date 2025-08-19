// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords {
    /// Reset the member’s password and authenticate them. This endpoint checks that the existing password matches the stored value.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the member is authenticated.
    func resetByExistingPassword(parameters: ResetByExistingPasswordParameters, completion: @escaping Completion<B2BPasswordExistingPasswordResetResponse>) {
        Task {
            do {
                completion(.success(try await resetByExistingPassword(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Reset the member’s password and authenticate them. This endpoint checks that the existing password matches the stored value.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the member is authenticated.
    func resetByExistingPassword(parameters: ResetByExistingPasswordParameters) -> AnyPublisher<B2BPasswordExistingPasswordResetResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByExistingPassword(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
