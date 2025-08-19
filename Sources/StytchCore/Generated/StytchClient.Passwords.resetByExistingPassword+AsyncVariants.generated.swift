// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Passwords {
    /// This method resets the user’s password using their existing password. This endpoint checks that the existing password matches the stored value.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the user is authenticated.
    func resetByExistingPassword(parameters: ResetByExistingPasswordParameters, completion: @escaping Completion<PasswordsExistingPasswordResetResponse>) {
        Task {
            do {
                completion(.success(try await resetByExistingPassword(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This method resets the user’s password using their existing password. This endpoint checks that the existing password matches the stored value.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the user is authenticated.
    func resetByExistingPassword(parameters: ResetByExistingPasswordParameters) -> AnyPublisher<PasswordsExistingPasswordResetResponse, Error> {
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
