// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.TOTP {
    /// Wraps Stytch's [create](https://stytch.com/docs/api/totp-create) endpoint. Call this method to create a new TOTP instance for a user. The user can use the authenticator application of their choice to scan the QR code or enter the secret.
    func create(parameters: CreateParameters, completion: @escaping Completion<CreateResponse>) {
        Task {
            do {
                completion(.success(try await create(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [create](https://stytch.com/docs/api/totp-create) endpoint. Call this method to create a new TOTP instance for a user. The user can use the authenticator application of their choice to scan the QR code or enter the secret.
    func create(parameters: CreateParameters) -> AnyPublisher<CreateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await create(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
