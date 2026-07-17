// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
public extension StytchClient.Passkeys {
    /// Registers a passkey with the device and with Stytch's servers for the authenticated user. Alongside the Stytch response, returns the ceremony's raw CBOR attestation object, whose attested credential data (e.g. the AAGUID identifying the passkey provider) exists only at registration time and is not stored by Stytch — callers may parse it to power passkey-management UIs.
    func register(parameters: RegisterParameters, completion: @escaping Completion<(response: BasicResponse, attestationObject: Data)>) {
        Task {
            do {
                completion(.success(try await register(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Registers a passkey with the device and with Stytch's servers for the authenticated user. Alongside the Stytch response, returns the ceremony's raw CBOR attestation object, whose attested credential data (e.g. the AAGUID identifying the passkey provider) exists only at registration time and is not stored by Stytch — callers may parse it to power passkey-management UIs.
    func register(parameters: RegisterParameters) -> AnyPublisher<(response: BasicResponse, attestationObject: Data), Error> {
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
