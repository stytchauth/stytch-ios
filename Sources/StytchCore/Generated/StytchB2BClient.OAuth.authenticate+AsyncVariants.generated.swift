// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.OAuth {
    /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<B2BMFAAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// After an identity provider confirms the identity of a user, this method authenticates the included token and returns a new session object.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<B2BMFAAuthenticateResponse, Error> {
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
