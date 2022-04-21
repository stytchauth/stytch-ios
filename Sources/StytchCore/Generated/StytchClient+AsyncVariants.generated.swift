// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

// MARK: - handle Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient {
    static func handle(url: URL, sessionDuration: Minutes) -> AnyPublisher<DeeplinkHandledStatus, Error> {
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
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus {
        try await withCheckedThrowingContinuation { continuation in
            handle(url: url, sessionDuration: sessionDuration, completion: continuation.resume)
        }
    }
    #else
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus {
        try await withCheckedThrowingContinuation { continuation in
            handle(url: url, sessionDuration: sessionDuration, completion: continuation.resume)
        }
    }
    #endif
}
#endif
