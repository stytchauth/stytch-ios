// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.Passwords {
    /// This method allows you to check whether or not the user’s provided password is valid, and to provide feedback to the user on how to increase the strength of their password.
    /// 
    /// Passwords are considered invalid if either of the following is true:
    /// 
    /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2.
    /// 2. The password is present in the HaveIBeenPwned dataset.
    /// 
    /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password. If you do not pass the email, it is possible that the password will evaluate as valid – but will fail with a weak_password error when used in the ``StytchClient/Passwords-swift.struct/create(parameters:)`` method.
    /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors that feedback provided by the zxcvbn library.
    func strengthCheck(parameters: StrengthCheckParameters, completion: @escaping Completion<StrengthCheckResponse>) {
        Task {
            do {
                completion(.success(try await strengthCheck(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This method allows you to check whether or not the user’s provided password is valid, and to provide feedback to the user on how to increase the strength of their password.
    /// 
    /// Passwords are considered invalid if either of the following is true:
    /// 
    /// 1. [zxcvbn](https://github.com/dropbox/zxcvbn)'s strength score is <= 2.
    /// 2. The password is present in the HaveIBeenPwned dataset.
    /// 
    /// This method takes `email` as an optional argument, and if it is passed it will be factored into zxcvbn’s evaluation of the strength of the password. If you do not pass the email, it is possible that the password will evaluate as valid – but will fail with a weak_password error when used in the ``StytchClient/Passwords-swift.struct/create(parameters:)`` method.
    /// Feedback will be present in the response for any password that does not meet the strength requirements, and mirrors that feedback provided by the zxcvbn library.
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
