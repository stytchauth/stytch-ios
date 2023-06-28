// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.MagicLinks.Email {
    /// Wraps Stytch's email magic link [login_or_signup](https://stytch.com/docs/b2b/api/send-login-signup-email) endpoint. Requests an email magic link for a member to log in or signup depending on the presence and/or status of an existing account.
    func loginOrSignup(parameters: Parameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await loginOrSignup(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's email magic link [login_or_signup](https://stytch.com/docs/b2b/api/send-login-signup-email) endpoint. Requests an email magic link for a member to log in or signup depending on the presence and/or status of an existing account.
    func loginOrSignup(parameters: Parameters) -> AnyPublisher<BasicResponse, Error> {
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
