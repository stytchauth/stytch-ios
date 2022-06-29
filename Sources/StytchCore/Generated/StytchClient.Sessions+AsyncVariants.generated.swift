// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

// MARK: - authenticate Combine
#if canImport(Combine)
import Combine

public extension StytchClient.Sessions {
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid, returning both an opaque sessionToken and sessionJwt for this session. The sessionJwt will have a fixed lifetime of five minutes regardless of the underlying session duration, though it will be refreshed automatically in the background after a successful authentication.
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
    /// Wraps Stytch's [authenticate](https://stytch.com/docs/api/session-auth) Session endpoint and validates that the session issued to the user is still valid, returning both an opaque sessionToken and sessionJwt for this session. The sessionJwt will have a fixed lifetime of five minutes regardless of the underlying session duration, though it will be refreshed automatically in the background after a successful authentication.
    func authenticate(parameters: AuthenticateParameters) async throws -> SessionsAuthenticateResponse {
        try await withCheckedThrowingContinuation { continuation in
            authenticate(parameters: parameters, completion: continuation.resume)
        }
    }
}
#endif

import Foundation

// MARK: - revoke Combine
#if canImport(Combine)
import Combine

public extension StytchClient.Sessions {
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
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
    /// Wraps Stytch's [revoke](https://stytch.com/docs/api/session-revoke) Session endpoint and revokes the user's current session. This method should be used to log out a user. A successful revocation will terminate session-refresh polling.
    func revoke() async throws -> SessionsRevokeResponse {
        try await withCheckedThrowingContinuation { continuation in
            revoke(completion: continuation.resume)
        }
    }
}
#endif
