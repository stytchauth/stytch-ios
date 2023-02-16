// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

public extension StytchClient {
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
    static func handle(url: URL, sessionDuration: Minutes = .defaultSessionDuration, completion: @escaping Completion<DeeplinkHandledStatus<AuthenticateResponse>>) {
        Task {
            do {
                completion(.success(try await handle(url: url, sessionDuration: sessionDuration)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
    static func handle(url: URL, sessionDuration: Minutes = .defaultSessionDuration) -> AnyPublisher<DeeplinkHandledStatus<AuthenticateResponse>, Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await handle(url: url, sessionDuration: sessionDuration)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
