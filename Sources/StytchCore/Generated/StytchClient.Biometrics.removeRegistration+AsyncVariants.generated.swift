// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Biometrics {
    /// Removes the current device's existing biometric registration from both the device itself and from the server.
    func removeRegistration(completion: @escaping Completion<Void>) {
        Task {
            do {
                completion(.success(try await removeRegistration()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Removes the current device's existing biometric registration from both the device itself and from the server.
    func removeRegistration() -> AnyPublisher<Void, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await removeRegistration()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
