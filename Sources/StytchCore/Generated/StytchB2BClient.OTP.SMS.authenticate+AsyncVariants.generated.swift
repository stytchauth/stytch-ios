// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.OTP.SMS {
    /// Authenticate a one-time passcode (OTP) sent to a user via SMS.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<StytchB2BClient.OTP.OTPAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Authenticate a one-time passcode (OTP) sent to a user via SMS.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<StytchB2BClient.OTP.OTPAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await authenticate(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
