import Foundation

/**
 The entrypoint for all Stytch-related interaction.

 The StytchClient provides static-variable interfaces for all supported Stytch products, e.g. `StytchClient.magicLinks.email`.

 **Async Options**: Async function calls for Stytch products are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 */
public struct StytchClient: StytchClientType {
    static var instance: StytchClient = .init()

    static var router: NetworkingRouter<BaseRoute> = .init { instance.configuration }

    private init() {
        postInit()
    }

    /**
     Configures the `StytchClient`, setting the `publicToken` and `hostUrl`.
     - Parameters:
       - publicToken: Available via the Stytch dashboard in the `API keys` section
       - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which will be used as the domain for setting session-token cookies to be sent to your servers on subsequent requests. If not passed here, no cookies will be set on your behalf.
     */
    public static func configure(publicToken: String, hostUrl: URL? = nil) {
        _configure(publicToken: publicToken, hostUrl: hostUrl)
    }

    ///  A helper function for parsing out the Stytch token types and values from a given deeplink
    public static func tokenValues(for url: URL) throws -> (DeeplinkTokenType, String)? {
        try _tokenValues(for: url)
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponse`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The duration, in minutes, of the requested session. Defaults to 30 minutes.
    public static func handle(
        url: URL,
        sessionDuration: Minutes = .defaultSessionDuration
    ) async throws -> DeeplinkHandledStatus<AuthenticateResponse> {
        guard let (tokenType, token) = try tokenValues(for: url) else {
            return .notHandled
        }

        switch tokenType {
        case .magicLinks:
            return try await .handled(magicLinks.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration)))
        case .oauth:
            return try await .handled(oauth.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration)))
        case .passwordReset:
            return .manualHandlingRequired(tokenType, token: token)
        case .multiTenantMagicLinks:
            return .notHandled
        }
    }
}
