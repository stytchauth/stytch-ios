// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Sessions {
    /// Exchange an auth token issued by a trusted identity provider for a Stytch session.
    /// You must first register a Trusted Auth Token profile in the Stytch dashboard (https://stytch.com/dashboard/trusted-auth-tokens).
    /// If a session token or session JWT is provided, it will add the trusted auth token as an authentication factor to the existing session.
    func attest(parameters: AttestParameters, completion: @escaping Completion<B2BAuthenticateResponse>) {
        Task {
            do {
                completion(.success(try await attest(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Exchange an auth token issued by a trusted identity provider for a Stytch session.
    /// You must first register a Trusted Auth Token profile in the Stytch dashboard (https://stytch.com/dashboard/trusted-auth-tokens).
    /// If a session token or session JWT is provided, it will add the trusted auth token as an authentication factor to the existing session.
    func attest(parameters: AttestParameters) -> AnyPublisher<B2BAuthenticateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await attest(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
