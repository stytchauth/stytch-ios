// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.MagicLinks.Email {
    /// Wraps Stytch's email magic link [send](https://stytch.com/docs/api/send-by-email) endpoint. Requests an email magic link for an existing user to log in or to attach the included email factor to their current account.
    func send(parameters: SendParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await send(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's email magic link [send](https://stytch.com/docs/api/send-by-email) endpoint. Requests an email magic link for an existing user to log in or to attach the included email factor to their current account.
    func send(parameters: SendParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await send(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
