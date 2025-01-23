import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

/**
 The entrypoint for all Stytch-related interaction.

 The StytchClient provides static-variable interfaces for all supported Stytch products, e.g. `StytchClient.magicLinks.email`.

 **Async Options**: Async function calls for Stytch products are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 */
public struct StytchClient: StytchClientType {
    static var instance: StytchClient = .init()
    static var router: NetworkingRouter<BaseRoute> = .init { instance.configuration }
    public static var isInitialized: AnyPublisher<Bool, Never> { StartupClient.isInitialized }
    // swiftlint:disable:next identifier_name
    public static var _uiRouter: NetworkingRouter<UIRoute> { router.scopedRouter { $0.ui } }

    public static var disableSdkWatermark: Bool {
        Current.localStorage.bootstrapData?.disableSdkWatermark ?? true
    }

    public static var passwordConfig: PasswordConfig? {
        Current.localStorage.bootstrapData?.passwordConfig
    }

    private init() {
        #if os(iOS)
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { _ in
            Task {
                try await StartupClient.start(type: ClientType.consumer)
            }
        }
        #endif
    }

    /**
     Configures the `StytchClient`, setting the `publicToken` and `hostUrl`.
     - Parameters:
       - publicToken: Available via the Stytch dashboard in the `API keys` section
       - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which will be used as the domain for setting session-token cookies to be sent to your servers on subsequent requests. If not passed here, no cookies will be set on your behalf.
       - dfppaDomain: The domain that should be used for DFPPA
     */
    public static func configure(publicToken: String, hostUrl: URL? = nil, dfppaDomain: String? = nil) {
        instance.configure(publicToken: publicToken, hostUrl: hostUrl, dfppaDomain: dfppaDomain)
    }

    ///  A helper function for parsing out the Stytch token types and values from a given deeplink
    // swiftlint:disable:next large_tuple
    public static func tokenValues(for url: URL) throws -> (DeeplinkTokenType, DeeplinkRedirectType, String)? {
        guard let (type, _, token) = try _tokenValues(for: url) else { return nil }
        guard let tokenType = DeeplinkTokenType(rawValue: type) else { throw StytchSDKError.deeplinkUnknownTokenType }
        return (tokenType, .unknown, token)
    }

    /// Retrieve the most recently created PKCE code pair from the device, if available
    public static func getPKCECodePair() -> PKCECodePair? {
        Self.instance.pkcePairManager.getPKCECodePair()
    }
}

public extension StytchClient {
    func start() {
        Task {
            do {
                try await StartupClient.start(type: ClientType.consumer)
                try? await EventsClient.logEvent(parameters: .init(eventName: "client_initialization_success"))
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "client_initialization_failure"))
            }
        }
    }
}

public extension StytchClient {
    /// Represents the type of deeplink token which has been parsed. e.g. `magicLinks` or `passwordReset`.
    enum DeeplinkTokenType: String, Sendable {
        case magicLinks = "magic_links"
        case oauth
        case passwordReset = "reset_password"
    }

    /// Wrapper around the possible types returned from the `handle(url:sessionDuration:)` function.
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
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The duration, in minutes, of the requested session. Defaults to 5 minutes.
    static func handle(
        url: URL,
        sessionDuration: Minutes = .defaultSessionDuration
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
            return try await .handled(response: .auth(magicLinks.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))))
        case .oauth:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .oauth(oauth.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))))
        case .passwordReset:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return .manualHandlingRequired(tokenType, redirectType, token: token)
        }
    }
}
