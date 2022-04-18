// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - authenticate Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient.MagicLinks {
    func authenticate(parameters: AuthenticateParameters) -> AnyPublisher<AuthenticateResponse, Error> {
        return Deferred { 
            Future({ promise in
                self.authenticate(parameters: parameters, completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - authenticate Async/Await
#if compiler(>=5.5) && canImport(_Concurrency)
public extension StytchClient.MagicLinks {
    #if compiler(>=5.5.2)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.authenticate(parameters: parameters, completion: continuation.resume)
        }
    }
    #else
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func authenticate(parameters: AuthenticateParameters) async throws -> AuthenticateResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.authenticate(parameters: parameters, completion: continuation.resume)
        }
    }
    #endif
}
#endif
