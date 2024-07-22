// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.RecoveryCodes {
    /// Consume a recovery code for a member
    func recover(parameters: RecoveryCodesRecoverParameters, completion: @escaping Completion<RecoveryCodesRecoverResponse>) {
        Task {
            do {
                completion(.success(try await recover(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Consume a recovery code for a member
    func recover(parameters: RecoveryCodesRecoverParameters) -> AnyPublisher<RecoveryCodesRecoverResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await recover(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
