import Foundation
import Combine

/**
 The entrypoint for all Stytch B2B-related interaction.

 The StytchB2BClient provides static-variable interfaces for all supported Stytch products, e.g. `StytchB2BClient.magicLinks.email`.

 **Async Options**: Async function calls for Stytch products are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 */
public struct StytchB2BClient: StytchClientType {
    static var instance: StytchB2BClient = .init()
    static let router: NetworkingRouter<BaseRoute> = .init { instance.configuration }
    public static var isInitialized: AnyPublisher<Bool, Never> { instance.initializationState.isInitialized }

    private init() {
        postInit()
    }

    /**
     Configures the `StytchB2BClient`, setting the `publicToken` and `hostUrl`.
     - Parameters:
       - publicToken: Available via the Stytch dashboard in the `API keys` section
       - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which will be used as the domain for setting session-token cookies to be sent to your servers on subsequent requests.
     */
    public static func configure(publicToken: String, hostUrl: URL? = nil) {
        _configure(publicToken: publicToken, hostUrl: hostUrl)
    }

    ///  A helper function for parsing out the Stytch token types and values from a given deeplink
    public static func tokenValues(for url: URL) throws -> (DeeplinkTokenType, String)? {
        guard let (type, token) = try _tokenValues(for: url) else { return nil }
        guard let tokenType = DeeplinkTokenType(rawValue: type) else { throw StytchError.unrecognizedDeeplinkTokenType }
        return (tokenType, token)
    }

    /// A helper function for determining whether the deeplink is intended for Stytch. Useful in contexts where your application makes use of a deeplink coordinator/manager which requires a synchronous determination of whether a given handler can handle a given URL. Equivalent to checking for a nil return value from ``StytchB2BClient/tokenValues(for:)``
    public static func canHandle(url: URL) -> Bool {
        (try? _tokenValues(for: url)) != nil
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
    public static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType> {
        guard let (tokenType, token) = try tokenValues(for: url) else {
            return .notHandled
        }

        switch tokenType {
        case .discovery:
            return try await .handled(.discovery(magicLinks.discoveryAuthenticate(parameters: .init(token: token))))
        case .multiTenantMagicLinks:
            return try await .handled(.auth(magicLinks.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))))
        case .multiTenantPasswords:
            return .manualHandlingRequired(.multiTenantPasswords, token: token)
        #if !os(watchOS)
        case .sso:
            return try await .handled(.auth(sso.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration))))
        #endif
        }
    }
}

public extension StytchB2BClient {
    /// Represents the type of deeplink token which has been parsed. e.g. `discovery` or `sso`.
    enum DeeplinkTokenType: String {
        case discovery
        case multiTenantMagicLinks = "multi_tenant_magic_links"
        case multiTenantPasswords = "multi_tenant_passwords"
        #if !os(watchOS)
        case sso
        #endif
    }

    /// Wrapper around the possible types returned from the `handle(url:sessionDuration:)` function.
    enum DeeplinkResponse {
        case auth(B2BAuthenticateResponse)
        case discovery(StytchB2BClient.MagicLinks.DiscoveryAuthenticateResponse)
    }
}
