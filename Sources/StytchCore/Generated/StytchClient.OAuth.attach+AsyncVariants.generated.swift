// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OAuth {
    /// Generate an OAuth Attach Token to pre-associate an OAuth flow with an existing Stytch User.
    /// You must have an active Stytch session to use this endpoint.
    /// Pass the returned oauth_attach_token to the same provider's OAuth Start endpoint to treat this OAuth flow as a login for that user instead of a signup for a new user.
    func attach(parameters: AttachParameters, completion: @escaping Completion<OAuthAttachResponse>) {
        Task {
            do {
                completion(.success(try await attach(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Generate an OAuth Attach Token to pre-associate an OAuth flow with an existing Stytch User.
    /// You must have an active Stytch session to use this endpoint.
    /// Pass the returned oauth_attach_token to the same provider's OAuth Start endpoint to treat this OAuth flow as a login for that user instead of a signup for a new user.
    func attach(parameters: AttachParameters) -> AnyPublisher<OAuthAttachResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await attach(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
