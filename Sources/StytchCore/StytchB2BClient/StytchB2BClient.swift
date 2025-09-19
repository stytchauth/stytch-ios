import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

// swiftlint:disable prefer_self_in_static_references

/**
 The entrypoint for all Stytch B2B-related interaction.

 The StytchB2BClient provides static-variable interfaces for all supported Stytch products, e.g. `StytchB2BClient.magicLinks.email`.

 **Async Options**: Async function calls for Stytch products are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 */
public struct StytchB2BClient: StytchClientCommonInternal {
    internal static var shared = StytchB2BClient()

    static let router: NetworkingRouter<BaseRoute> = .init {
        stytchClientConfiguration
    }

    public static var lastAuthMethodUsed: B2BAuthMethod {
        Current.sessionManager.b2bLastAuthMethodUsed
    }

    public static var clientType: ClientType {
        .b2b
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
        guard let (type, redirectTypeString, token) = try _tokenValues(for: url) else {
            return nil
        }

        guard let tokenType = DeeplinkTokenType(rawValue: type) else {
            throw StytchSDKError.deeplinkUnknownTokenType
        }

        let redirectType = DeeplinkRedirectType(redirectTypeString)

        return (tokenType, redirectType, token)
    }
}

public extension StytchB2BClient {
    /// Represents the type of deeplink token which has been parsed. e.g. `discovery` or `sso`.
    enum DeeplinkTokenType: String, Sendable {
        case discovery
        case multiTenantMagicLinks = "multi_tenant_magic_links"
        case multiTenantPasswords = "multi_tenant_passwords"
        #if !os(watchOS)
        case sso
        case oauth
        case discoveryOauth = "discovery_oauth"
        #endif
    }

    enum DeeplinkRedirectType: String, Sendable {
        case login
        case resetPassword = "reset_password"
        case unknown

        init(_ string: String?) {
            if let value = string, let type = Self(rawValue: value) {
                self = type
            } else {
                self = .unknown
            }
        }
    }

    /// Wrapper around the possible types returned from the `handle(url:sessionDurationMinutes:)` function.
    enum DeeplinkResponse: Sendable {
        case mfauth(B2BMFAAuthenticateResponse)
        case mfaOAuth(StytchB2BClient.OAuth.OAuthAuthenticateResponse)
        case discovery(StytchB2BClient.DiscoveryAuthenticateResponse)
        #if !os(watchOS)
        case discoveryOauth(StytchB2BClient.DiscoveryAuthenticateResponse)
        #endif
    }

    /// A helper function for determining whether the deeplink is intended for Stytch. Useful in contexts where your application makes use of a deeplink coordinator/manager which requires a synchronous determination of whether a given handler can handle a given URL. Equivalent to checking for a nil return value from ``StytchB2BClient/tokenValues(for:)``
    static func canHandle(url: URL) -> Bool {
        (try? _tokenValues(for: url)) != nil
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDurationMinutes` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDurationMinutes: The duration, in minutes, of the requested session. Defaults to 5 minutes.
    static func handle(url: URL, sessionDurationMinutes: Minutes = StytchB2BClient.defaultSessionDuration) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType> {
        guard let (tokenType, redirectType, token) = try tokenValues(for: url) else {
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_failure", details: ["token_type": "UNKNOWN"]))
            }
            return .notHandled
        }

        switch tokenType {
        case .discovery:
            switch redirectType {
            case .resetPassword:
                Task {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
                }
                return .manualHandlingRequired(.discovery, redirectType, token: token)
            case .login, .unknown:
                Task {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
                }
                return try await .handled(response: .discovery(magicLinks.discoveryAuthenticate(parameters: .init(discoveryMagicLinksToken: token))))
            }
        case .multiTenantMagicLinks:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .mfauth(magicLinks.authenticate(parameters: .init(magicLinksToken: token, sessionDurationMinutes: sessionDurationMinutes))))
        case .multiTenantPasswords:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return .manualHandlingRequired(.multiTenantPasswords, redirectType, token: token)
        #if !os(watchOS)
        case .sso:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .mfauth(sso.authenticate(parameters: .init(ssoToken: token, sessionDurationMinutes: sessionDurationMinutes))))
        case .oauth:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .mfaOAuth(oauth.authenticate(parameters: .init(oauthToken: token, sessionDurationMinutes: sessionDurationMinutes))))
        case .discoveryOauth:
            Task {
                try? await EventsClient.logEvent(parameters: .init(eventName: "deeplink_handled_success", details: ["token_type": tokenType.rawValue]))
            }
            return try await .handled(response: .discoveryOauth(oauth.discovery.authenticate(parameters: .init(discoveryOauthToken: token))))
        #endif
        }
    }
}
