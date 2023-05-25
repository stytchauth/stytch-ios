// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchB2BClient.Passwords {
    /// This method allows you to check whether the member's provided password is valid, and to provide feedback to the member on how to increase the strength of their password.
    /// 
    /// Passwords are considered invalid if one of the following is true:
    /// 
    /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2 (if using zxcvbn).
    /// 1. The configured LUDS requirements have not been met.
    /// 2. The password is present in the HaveIBeenPwned dataset.
    /// 
    /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password.
    /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors the feedback of the zxcvbn or LUDS analysis.
    func strengthCheck(parameters: StrengthCheckParameters, completion: @escaping Completion<StrengthCheckResponse>) {
        Task {
            do {
                completion(.success(try await strengthCheck(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This method allows you to check whether the member's provided password is valid, and to provide feedback to the member on how to increase the strength of their password.
    /// 
    /// Passwords are considered invalid if one of the following is true:
    /// 
    /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2 (if using zxcvbn).
    /// 1. The configured LUDS requirements have not been met.
    /// 2. The password is present in the HaveIBeenPwned dataset.
    /// 
    /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password.
    /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors the feedback of the zxcvbn or LUDS analysis.
    func strengthCheck(parameters: StrengthCheckParameters) -> AnyPublisher<StrengthCheckResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await strengthCheck(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
