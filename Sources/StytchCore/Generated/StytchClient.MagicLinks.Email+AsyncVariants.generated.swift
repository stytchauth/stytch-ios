// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - loginOrCreate Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient.MagicLinks.Email {
    /// Wraps Stytch's email magiclink `login_or_create` endpoint. Requests an email magiclink for a user to
    /// either log in or create an account depending on the presence/status of their current account.
    func loginOrCreate(parameters: EmailParameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred { 
            Future({ promise in
                self.loginOrCreate(parameters: parameters, completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - loginOrCreate Async/Await
#if compiler(>=5.5) && canImport(_Concurrency)
public extension StytchClient.MagicLinks.Email {
    #if compiler(>=5.5.2)
    /// Wraps Stytch's email magiclink `login_or_create` endpoint. Requests an email magiclink for a user to
    /// either log in or create an account depending on the presence/status of their current account.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func loginOrCreate(parameters: EmailParameters) async throws -> BasicResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.loginOrCreate(parameters: parameters, completion: continuation.resume)
        }
    }
    #else
    /// Wraps Stytch's email magiclink `login_or_create` endpoint. Requests an email magiclink for a user to
    /// either log in or create an account depending on the presence/status of their current account.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func loginOrCreate(parameters: EmailParameters) async throws -> BasicResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.loginOrCreate(parameters: parameters, completion: continuation.resume)
        }
    }
    #endif
}
#endif
