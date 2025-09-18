// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient {
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDurationMinutes` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
    static func handle(url: URL, sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration, completion: @escaping Completion<DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType>>) {
        Task {
            do {
                completion(.success(try await handle(url: url, sessionDurationMinutes: sessionDurationMinutes)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDurationMinutes` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
    static func handle(url: URL, sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration) -> AnyPublisher<DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType>, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await handle(url: url, sessionDurationMinutes: sessionDurationMinutes)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
