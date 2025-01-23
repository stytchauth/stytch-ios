// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords.Discovery {
    /// Initiates a password reset for the email address provided, when cross-org passwords are enabled.
    /// This will trigger an email to be sent to the address, containing a magic link that will allow them to set a new password and authenticate.
    func resetByEmailStart(parameters: ResetByEmailStartParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await resetByEmailStart(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Initiates a password reset for the email address provided, when cross-org passwords are enabled.
    /// This will trigger an email to be sent to the address, containing a magic link that will allow them to set a new password and authenticate.
    func resetByEmailStart(parameters: ResetByEmailStartParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await resetByEmailStart(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
