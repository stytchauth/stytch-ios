// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Biometrics {
    /// When a valid/active session exists, this method will add a biometric registration for the current user. The user will later be able to start a new session with biometrics or use biometrics as an additional authentication factor.
    /// 
    /// NOTE: - You should ensure the `accessPolicy` parameters match your particular needs, defaults to `deviceOwnerWithBiometrics`.
    func register(parameters: RegisterParameters, completion: @escaping Completion<AuthenticateResponseType>) {
        Task {
            do {
                completion(.success(try await register(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// When a valid/active session exists, this method will add a biometric registration for the current user. The user will later be able to start a new session with biometrics or use biometrics as an additional authentication factor.
    /// 
    /// NOTE: - You should ensure the `accessPolicy` parameters match your particular needs, defaults to `deviceOwnerWithBiometrics`.
    func register(parameters: RegisterParameters) -> AnyPublisher<AuthenticateResponseType, Error> {
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
