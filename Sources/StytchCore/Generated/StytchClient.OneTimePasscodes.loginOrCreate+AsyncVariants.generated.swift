// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OneTimePasscodes {
    /// Wraps Stytch's OTP [sms/login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-sms), [whatsapp/login_or_create](https://stytch.com/docs/api/whatsapp-login-or-create), and [email/login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email-otp) endpoints. Requests a one-time passcode for a user to log in or create an account depending on the presence and/or status current account.
    func loginOrCreate(parameters: Parameters, completion: @escaping Completion<OTPResponse>) {
        Task {
            do {
                completion(.success(try await loginOrCreate(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's OTP [sms/login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-sms), [whatsapp/login_or_create](https://stytch.com/docs/api/whatsapp-login-or-create), and [email/login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email-otp) endpoints. Requests a one-time passcode for a user to log in or create an account depending on the presence and/or status current account.
    func loginOrCreate(parameters: Parameters) -> AnyPublisher<OTPResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await loginOrCreate(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
