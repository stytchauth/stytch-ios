// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
public extension StytchClient.Passkeys {
    /// Registers a passkey with the device and with Stytch's servers for the authenticated user.
    func register(parameters: RegisterParameters, completion: @escaping Completion<BasicResponse>) {
        Task {
            do {
                completion(.success(try await register(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Registers a passkey with the device and with Stytch's servers for the authenticated user.
    func register(parameters: RegisterParameters) -> AnyPublisher<BasicResponse, Error> {
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
