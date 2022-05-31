// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

// MARK: - handle Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient {
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The desired session duration in ``Minutes``. Defaults to 30.
    ///  - Returns: A ``DeeplinkHandledStatus`` will be returned asynchronously.
    static func handle(url: URL, sessionDuration: Minutes = 30) -> AnyPublisher<DeeplinkHandledStatus, Error> {
        return Deferred { 
            Future({ promise in
                handle(url: url, sessionDuration: sessionDuration, completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - handle Async/Await
#if compiler(>=5.5) && canImport(_Concurrency)
public extension StytchClient {
    #if compiler(>=5.5.2)
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The desired session duration in ``Minutes``. Defaults to 30.
    ///  - Returns: A ``DeeplinkHandledStatus`` will be returned asynchronously.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    static func handle(url: URL, sessionDuration: Minutes = 30) async throws -> DeeplinkHandledStatus {
        try await withCheckedThrowingContinuation { continuation in
            handle(url: url, sessionDuration: sessionDuration, completion: continuation.resume)
        }
    }
    #else
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The desired session duration in ``Minutes``. Defaults to 30.
    ///  - Returns: A ``DeeplinkHandledStatus`` will be returned asynchronously.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func handle(url: URL, sessionDuration: Minutes = 30) async throws -> DeeplinkHandledStatus {
        try await withCheckedThrowingContinuation { continuation in
            handle(url: url, sessionDuration: sessionDuration, completion: continuation.resume)
        }
    }
    #endif
}
#endif
