// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Passwords {
    /// This method resets the user’s password using their existing session. The endpoint will error if the session does not have a password, email magic link, or email OTP authentication factor that has been issued within the last 5 minutes.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the user is authenticated.
    func resetBySession(parameters: ResetBySessionParameters, completion: @escaping Completion<AuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await resetBySession(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This method resets the user’s password using their existing session. The endpoint will error if the session does not have a password, email magic link, or email OTP authentication factor that has been issued within the last 5 minutes.
    /// 
    /// The provided password needs to meet our password strength requirements, which can be checked in advance with the password strength endpoint. If the token and password are accepted, the password is securely stored for future authentication and the user is authenticated.
    func resetBySession(parameters: ResetBySessionParameters) -> AnyPublisher<AuthenticateResponse, Error> {
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
