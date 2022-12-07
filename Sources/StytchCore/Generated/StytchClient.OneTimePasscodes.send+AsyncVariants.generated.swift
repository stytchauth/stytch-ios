// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient.OneTimePasscodes {
    /// Wraps Stytch's OTP [sms/send](https://stytch.com/docs/api/send-otp-by-sms), [whatsapp/send](https://stytch.com/docs/api/whatsapp-send), and [email/send](https://stytch.com/docs/api/send-otp-by-email) endpoints. Requests a one-time passcode for a user to log in or attach a new factor to their existing account.
    func send(parameters: Parameters, completion: @escaping Completion<OTPResponse>) {
        Task {
            do {
                completion(.success(try await send(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Wraps Stytch's OTP [sms/send](https://stytch.com/docs/api/send-otp-by-sms), [whatsapp/send](https://stytch.com/docs/api/whatsapp-send), and [email/send](https://stytch.com/docs/api/send-otp-by-email) endpoints. Requests a one-time passcode for a user to log in or attach a new factor to their existing account.
    func send(parameters: Parameters) -> AnyPublisher<OTPResponse, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await send(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
