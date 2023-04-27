// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchB2BClient.SSO {
    /// Authenticate a member given a token. This endpoint verifies that the memeber completed the SSO Authentication flow by
    /// verifying that the token is valid and hasn't expired.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<B2BAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Authenticate a member given a token. This endpoint verifies that the memeber completed the SSO Authentication flow by
    /// verifying that the token is valid and hasn't expired.
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
#endif
