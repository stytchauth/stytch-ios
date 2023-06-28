// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords {
    /// Authenticate a member with their email address and password. This method verifies that the member has a password currently set, and that the entered password is correct.
    /// 
    /// There are two instances where the endpoint will return a reset_password error even if they enter their previous password:
    /// 1. The member's credentials appeared in the HaveIBeenPwned dataset.
    ///   a. We force a password reset to ensure that the member is the legitimate owner of the email address, and not a malicious actor abusing the compromised credentials.
    /// 2. The member used email based authentication (e.g. Magic Links, Google OAuth) for the first time, and had not previously verified their email address for password based login.
    ///   a. We force a password reset in this instance in order to safely deduplicate the account by email address, without introducing the risk of a pre-hijack account-takeover attack.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<B2BAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Authenticate a member with their email address and password. This method verifies that the member has a password currently set, and that the entered password is correct.
    /// 
    /// There are two instances where the endpoint will return a reset_password error even if they enter their previous password:
    /// 1. The member's credentials appeared in the HaveIBeenPwned dataset.
    ///   a. We force a password reset to ensure that the member is the legitimate owner of the email address, and not a malicious actor abusing the compromised credentials.
    /// 2. The member used email based authentication (e.g. Magic Links, Google OAuth) for the first time, and had not previously verified their email address for password based login.
    ///   a. We force a password reset in this instance in order to safely deduplicate the account by email address, without introducing the risk of a pre-hijack account-takeover attack.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<B2BAuthenticateResponse, Error> {
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
