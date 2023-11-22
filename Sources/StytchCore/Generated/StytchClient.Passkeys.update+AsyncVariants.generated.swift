// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
@available(macOS 12.0, iOS 16.0, tvOS 16.0, *)
public extension StytchClient.Passkeys {
    /// Updates an existing passkey based on its ID
    func update(parameters: UpdateParameters, completion: @escaping Completion<PasskeysUpdateResponse>) {
        Task {
            do {
                completion(.success(try await update(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Updates an existing passkey based on its ID
    func update(parameters: UpdateParameters) -> AnyPublisher<PasskeysUpdateResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await update(parameters: parameters)))
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
