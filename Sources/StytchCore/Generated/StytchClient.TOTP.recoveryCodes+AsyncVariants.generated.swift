// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.TOTP {
    /// Wraps Stytch's [recovery_codes](https://stytch.com/docs/api/totp-get-recovery-codes) endpoint. Call this method to retrieve the recovery codes for a TOTP instance tied to a user. Note: If a user has enrolled another MFA method, this method will require MFA. See the [Multi-factor authentication](https://stytch.com/docs/sdks/javascript-sdk#resources_multi-factor-authentication) section for more details.
    func recoveryCodes(completion: @escaping Completion<RecoveryCodesResponse>) {
        Task {
            do {
                completion(.success(try await recoveryCodes()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's [recovery_codes](https://stytch.com/docs/api/totp-get-recovery-codes) endpoint. Call this method to retrieve the recovery codes for a TOTP instance tied to a user. Note: If a user has enrolled another MFA method, this method will require MFA. See the [Multi-factor authentication](https://stytch.com/docs/sdks/javascript-sdk#resources_multi-factor-authentication) section for more details.
    func recoveryCodes() -> AnyPublisher<RecoveryCodesResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await recoveryCodes()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
