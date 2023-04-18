// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords {
    /// Reset the member’s password and authenticate them. This endpoint checks that the magic link token is valid, hasn’t expired, or already been used.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the member is authenticated.
    func resetByEmail(parameters: ResetByEmailParameters, completion: @escaping Completion<B2BAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await resetByEmail(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Reset the member’s password and authenticate them. This endpoint checks that the magic link token is valid, hasn’t expired, or already been used.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the member is authenticated.
    func resetByEmail(parameters: ResetByEmailParameters) -> AnyPublisher<B2BAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByEmail(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
