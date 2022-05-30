// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

// MARK: - authenticate Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient.Sessions {
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid.
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<SessionsAuthenticateResponse, Error> {
        return Deferred { 
            Future({ promise in
                authenticate(parameters: parameters, completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - authenticate Async/Await
#if compiler(>=5.5) && canImport(_Concurrency)
public extension StytchClient.Sessions {
    #if compiler(>=5.5.2)
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func authenticate(parameters: AuthenticateParameters) async throws -> SessionsAuthenticateResponse {
        try await withCheckedThrowingContinuation { continuation in
            authenticate(parameters: parameters, completion: continuation.resume)
        }
    }
    #else
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func authenticate(parameters: AuthenticateParameters) async throws -> SessionsAuthenticateResponse {
        try await withCheckedThrowingContinuation { continuation in
            authenticate(parameters: parameters, completion: continuation.resume)
        }
    }
    #endif
}
#endif

import Foundation

// MARK: - revoke Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient.Sessions {
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user.
    func revoke() -> AnyPublisher<SessionsRevokeResponse, Error> {
        return Deferred { 
            Future({ promise in
                revoke(completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - revoke Async/Await
#if compiler(>=5.5) && canImport(_Concurrency)
public extension StytchClient.Sessions {
    #if compiler(>=5.5.2)
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func revoke() async throws -> SessionsRevokeResponse {
        try await withCheckedThrowingContinuation { continuation in
            revoke(completion: continuation.resume)
        }
    }
    #else
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func revoke() async throws -> SessionsRevokeResponse {
        try await withCheckedThrowingContinuation { continuation in
            revoke(completion: continuation.resume)
        }
    }
    #endif
}
#endif
