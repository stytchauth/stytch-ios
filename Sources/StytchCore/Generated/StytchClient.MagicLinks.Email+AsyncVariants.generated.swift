// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - loginOrCreate Combine
#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public extension StytchClient.MagicLinks.Email {
    /// loginOrCreate
    /// Does some stuff, as named.
    /// - Parameters:
    ///   - parameters: Email parameters
    ///   - return: Completion block
    func loginOrCreate(parameters: EmailParameters) -> AnyPublisher<EmailResponse, Error> {
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
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func loginOrCreate(parameters: EmailParameters) async throws -> EmailResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.loginOrCreate(parameters: parameters, completion: continuation.resume)
        }
    }
    #else
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func loginOrCreate(parameters: EmailParameters) async throws -> EmailResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.loginOrCreate(parameters: parameters, completion: continuation.resume)
        }
    }
    #endif
}
#endif
