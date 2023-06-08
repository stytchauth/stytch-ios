// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Combine
import Foundation

#if !os(watchOS)
public extension StytchClient.OAuth.ThirdParty {
    /// Initiates the OAuth flow by using the included parameters to generate a URL and start an `ASWebAuthenticationSession`.
    /// **NOTE:** The user will be prompted for permission to use "stytch.com" to sign in — you may want to inform your users of this expectation.
    /// The user will see an in-app browser—with shared sessions from their default browser—which will dismiss after completing the authentication challenge with the identity provider.
    /// 
    /// **Usage:**
    /// ``` swift
    /// let (token, url) = try await StytchClient.oauth.google.start(parameters: parameters)
    /// let authResponse = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
    /// // You can parse the returned `url` value to understand whether this authentication was a login or a signup.
    /// ```
    /// - Returns: A tuple containing an authentication token, for use in the ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd`` method as well as the redirect url to inform whether this authentication was a login or signup.
    @available(tvOS 16.0, *)
    func start(parameters: WebAuthSessionStartParameters, completion: @escaping Completion<(token: String, url: URL)>) {
        Task {
            do {
                completion(.success(try await start(parameters: parameters)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Initiates the OAuth flow by using the included parameters to generate a URL and start an `ASWebAuthenticationSession`.
    /// **NOTE:** The user will be prompted for permission to use "stytch.com" to sign in — you may want to inform your users of this expectation.
    /// The user will see an in-app browser—with shared sessions from their default browser—which will dismiss after completing the authentication challenge with the identity provider.
    /// 
    /// **Usage:**
    /// ``` swift
    /// let (token, url) = try await StytchClient.oauth.google.start(parameters: parameters)
    /// let authResponse = try await StytchClient.oauth.authenticate(parameters: .init(token: token))
    /// // You can parse the returned `url` value to understand whether this authentication was a login or a signup.
    /// ```
    /// - Returns: A tuple containing an authentication token, for use in the ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd`` method as well as the redirect url to inform whether this authentication was a login or signup.
    @available(tvOS 16.0, *)
    func start(parameters: WebAuthSessionStartParameters) -> AnyPublisher<(token: String, url: URL), Error> {
        return Deferred {
            Future({ promise in
                Task {
                    do {
                        promise(.success(try await start(parameters: parameters)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
#endif
