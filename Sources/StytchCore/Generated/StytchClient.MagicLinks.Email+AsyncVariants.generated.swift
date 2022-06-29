// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

// MARK: - loginOrCreate Combine
#if canImport(Combine)
import Combine

public extension StytchClient.MagicLinks.Email {
    /// Wraps Stytch's email magic link [login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email) endpoint. Requests an email magic link for a user to log in or create an account depending on the presence and/or status current account.
    func loginOrCreate(parameters: Parameters) -> AnyPublisher<BasicResponse, Error> {
        return Deferred { 
            Future({ promise in
                loginOrCreate(parameters: parameters, completion: promise)
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif

// MARK: - loginOrCreate Async/Await
#if compiler(>=5.5) && canImport(_Concurrency)
public extension StytchClient.MagicLinks.Email {
    /// Wraps Stytch's email magic link [login_or_create](https://stytch.com/docs/api/log-in-or-create-user-by-email) endpoint. Requests an email magic link for a user to log in or create an account depending on the presence and/or status current account.
    func loginOrCreate(parameters: Parameters) async throws -> BasicResponse {
        try await withCheckedThrowingContinuation { continuation in
            loginOrCreate(parameters: parameters, completion: continuation.resume)
        }
    }
}
#endif
