// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords {
    /// Reset the member’s password and authenticate them. This endpoint checks that the session is valid and hasn’t expired or been revoked.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the member is authenticated.
    func resetBySession(parameters: ResetBySessionParameters, completion: @escaping Completion<B2BAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await resetBySession(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Reset the member’s password and authenticate them. This endpoint checks that the session is valid and hasn’t expired or been revoked.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the password and accompanying parameters are accepted, the password is securely stored for future authentication and the member is authenticated.
    func resetBySession(parameters: ResetBySessionParameters) -> AnyPublisher<B2BAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetBySession(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
