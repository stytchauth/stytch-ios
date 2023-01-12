// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.TOTP {
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/totp-authenticate) endpoint. Call this method to authenticate a TOTP code entered by a user.
    func authenticate(parameters: AuthenticateParameters, completion: @escaping Completion<AuthenticateResponseType>) {
        Task {
            do {
                completion(.success(try await authenticate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/totp-authenticate) endpoint. Call this method to authenticate a TOTP code entered by a user.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<AuthenticateResponseType, Error> {
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
