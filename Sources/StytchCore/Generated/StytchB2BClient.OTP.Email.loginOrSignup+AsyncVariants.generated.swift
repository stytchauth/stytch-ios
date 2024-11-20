// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.OTP.Email {
    /// Send a one-time passcode (OTP) to a user using email address.
    func loginOrSignup(parameters: LoginOrSignupParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await loginOrSignup(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Send a one-time passcode (OTP) to a user using email address.
    func loginOrSignup(parameters: LoginOrSignupParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await loginOrSignup(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
