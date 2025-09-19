import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

// swiftlint:disable prefer_self_in_static_references

/**
 The entrypoint for all Stytch-related interaction.

 The StytchClient provides static-variable interfaces for all supported Stytch products, e.g. `StytchClient.magicLinks.email`.

 **Async Options**: Async function calls for Stytch products are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 */
public struct StytchClient: StytchClientCommonInternal {
    internal static var shared = StytchClient()

    static var router: NetworkingRouter<BaseRoute> = .init {
        stytchClientConfiguration
    }

    public static var lastAuthMethodUsed: ConsumerAuthMethod {
        Current.sessionManager.consumerLastAuthMethodUsed
    }

    public static var clientType: ClientType {
        .consumer
    }

    /**
     Configures the `StytchClient`
     - Parameters:
       - configuration: A flexible and extensible object requiring at least a public token, with optional additional settings.
     */
    public static func configure(configuration: StytchClientConfiguration) {
        shared.configure(newConfiguration: configuration)
    }

    // swiftlint:disable:next orphaned_doc_comment
    ///  A helper function for parsing out the Stytch token types and values from a given deeplink
    // swiftlint:disable:next large_tuple
    public static func tokenValues(for url: URL) throws -> (DeeplinkTokenType, DeeplinkRedirectType, String)? {
        guard let (type, _, token) = try _tokenValues(for: url) else {
            return nil
        }

        guard let tokenType = DeeplinkTokenType(rawValue: type) else {
            throw StytchSDKError.deeplinkUnknownTokenType
        }

        return (tokenType, .unknown, token)
    }
}

public extension StytchClient {
    /// Represents the type of deeplink token which has been parsed. e.g. `magicLinks` or `passwordReset`.
    enum DeeplinkTokenType: String, Sendable {
        case magicLinks = "magic_links"
        case oauth
        case passwordReset = "reset_password"
    }

    /// Wrapper around the possible types returned from the `handle(url:sessionDurationMinutes:)` function.
    enum DeeplinkResponse: Sendable {
        case auth(AuthenticateResponse)
        case oauth(StytchClient.OAuth.OAuthAuthenticateResponse)
    }

    enum DeeplinkRedirectType: Sendable {
        case unknown
    }

    /// A helper function for determining whether the deeplink is intended for Stytch. Useful in contexts where your application makes use of a deeplink coordinator/manager which requires a synchronous determination of whether a given handler can handle a given URL. Equivalent to checking for a nil return value from ``StytchClient/tokenValues(for:)``
    static func canHandle(url: URL) -> Bool {
        (try? tokenValues(for: url)) != nil
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDurationMinutes` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
    static func handle(
        url: URL,
        sessionDurationMinutes: Minutes = StytchClient.defaultSessionDuration
    ) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType> {
        guard let (tokenType, redirectType, token) = try tokenValues(for: url) else {
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_failure", details: ["token_type": "UNKNOWN"]))
            }
            return .notHandled
        }

        switch tokenType {
        case .magicLinks:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .auth(magicLinks.authenticate(parameters: .init(token: token, sessionDurationMinutes: sessionDurationMinutes))))
        case .oauth:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .oauth(oauth.authenticate(parameters: .init(token: token, sessionDurationMinutes: sessionDurationMinutes))))
        case .passwordReset:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return .manualHandlingRequired(tokenType, redirectType, token: token)
        }
    }
}
