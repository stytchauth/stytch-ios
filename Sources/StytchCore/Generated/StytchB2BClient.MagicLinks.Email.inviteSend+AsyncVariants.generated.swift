// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.MagicLinks.Email {
    /// The Send Invite Email method wraps the [send invite email](https://test.stytch.com/v1/b2b/magic_links/email/invite) API endpoint.
    func inviteSend(parameters: InviteParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await inviteSend(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// The Send Invite Email method wraps the [send invite email](https://test.stytch.com/v1/b2b/magic_links/email/invite) API endpoint.
    func inviteSend(parameters: InviteParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await inviteSend(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
