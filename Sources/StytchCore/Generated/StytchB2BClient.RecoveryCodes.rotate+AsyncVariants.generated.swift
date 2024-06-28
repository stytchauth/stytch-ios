// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.RecoveryCodes {
    /// Rotate the recovery codes for an authenticated member
    func rotate(completion: @escaping Completion<RecoveryCodesResponse>) {
        Task {
            do {
                completion(.success(try await rotate()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Rotate the recovery codes for an authenticated member
    func rotate() -> AnyPublisher<RecoveryCodesResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await rotate()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
