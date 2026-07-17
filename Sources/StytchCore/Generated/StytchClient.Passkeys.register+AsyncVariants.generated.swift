// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
public extension StytchClient.Passkeys {
    /// Registers a passkey with the device and with Stytch's servers for the authenticated user. Alongside the Stytch response, returns client-parsed authenticator info (AAGUID and backup flags) from the ceremony's attestation object — data Stytch does not store, so it is only available at this moment.
    func register(parameters: RegisterParameters, completion: @escaping Completion<(response: RegisterResponse, authenticatorInfo: PasskeyAuthenticatorInfo?)>) {
        Task {
            do {
                completion(.success(try await register(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Registers a passkey with the device and with Stytch's servers for the authenticated user. Alongside the Stytch response, returns client-parsed authenticator info (AAGUID and backup flags) from the ceremony's attestation object — data Stytch does not store, so it is only available at this moment.
    func register(parameters: RegisterParameters) -> AnyPublisher<(response: RegisterResponse, authenticatorInfo: PasskeyAuthenticatorInfo?), Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await register(parameters: parameters)))
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
