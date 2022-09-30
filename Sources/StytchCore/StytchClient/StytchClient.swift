import Foundation

/**
 The entrypoint for all Stytch-related interaction.

 The StytchClient provides static-variable interfaces for all supported Stytch products, e.g. `StytchClient.magicLinks.email`.

 **Async Options**: Async function calls for Stytch products are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 */
public struct StytchClient {
    static var instance: StytchClient = .init()

    static var router: NetworkingRouter<BaseRoute> = .init()

    private(set) var configuration: Configuration? = {
        guard let url = Bundle.main.url(forResource: "StytchConfiguration", withExtension: "plist"), let data = try? Data(contentsOf: url) else { return nil }

        return try? PropertyListDecoder().decode(Configuration.self, from: data)
    }() {
        didSet { updateHeaderProvider() }
    }

    private init() {
        updateHeaderProvider()
        runKeychainMigrations()
    }

    /**
     Configures the `StytchClient`, setting the `publicToken` and `hostUrl`.
     - Parameters:
       - publicToken: Available via the Stytch dashboard in the `API keys` section
       - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which will be used as the domain for setting session-token cookies to be sent to your servers on subsequent requests.
     */
    public static func configure(publicToken: String, hostUrl: URL) {
        instance.configuration = .init(hostUrl: hostUrl, publicToken: publicToken)
    }

    // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
    /// This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, an ``AuthenticateResponseType`` will be returned to you asynchronously, with a `sessionDuration` of
    /// the length requested here.
    ///  - Parameters:
    ///    - url: A `URL` passed to your application as a deeplink.
    ///    - sessionDuration: The desired session duration in ``Minutes``. Defaults to 30.
    public static func handle(
        url: URL,
        sessionDuration: Minutes = .defaultSessionDuration
    ) async throws -> DeeplinkHandledStatus {
        guard let (tokenType, token) = try tokenValues(for: url) else {
            return .notHandled
        }

        switch tokenType {
        case .magicLinks:
            return try await .handled(magicLinks.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration)))
        case .oauth:
            return try await .handled(oauth.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration)))
        case .passwordReset:
            return .manualHandlingRequired(.passwordReset, token: token)
        }
    }

    ///  A helper function for parsing out the Stytch token types and values from a given deeplink
    public static func tokenValues(for url: URL) throws -> (DeeplinkTokenType, String)? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let typeQuery = queryItems.first(where: { $0.name == "stytch_token_type" }), let type = typeQuery.value,
            let tokenQuery = queryItems.first(where: { $0.name == "token" }), let token = tokenQuery.value
        else {
            return nil
        }
        guard let tokenType = DeeplinkTokenType(rawValue: type) else {
            throw StytchError.unrecognizedDeeplinkTokenType
        }
        return (tokenType, token)
    }

    // To be called after configuration
    private func updateHeaderProvider() {
        let clientInfoString = try? Current.clientInfo.base64EncodedString()

        Current.networkingClient.headerProvider = {
            guard let configuration = Self.instance.configuration else { return [:] }

            let sessionToken = Current.sessionStorage.sessionToken?.value ?? configuration.publicToken
            let authToken = "\(configuration.publicToken):\(sessionToken)".base64Encoded()

            return [
                "Content-Type": "application/json",
                "Authorization": "Basic \(authToken)",
                "X-SDK-Client": clientInfoString ?? "",
            ]
        }
    }

    private func runKeychainMigrations() {
        KeychainClient.migrations.forEach { migration in
            let migrationName = "stytch_keychain_migration_" + String(describing: migration.self)
            guard !Current.defaults.bool(forKey: migrationName) else {
                return
            }
            do {
                try migration.run()
                Current.defaults.set(true, forKey: migrationName)
            } catch {
                print(error)
            }
        }
    }
}

public extension StytchClient {
    /**
     Represents whether a deeplink was able to be handled
     Session-related information when appropriate.
     */
    enum DeeplinkHandledStatus {
        /// The handler was successfully able to handle the given item.
        case handled(AuthenticateResponseType)
        /// The handler was unable to handle the given item.
        case notHandled
        /// The handler recognized the token type, but manual handing is required. This should only be encountered for password reset deeplinks.
        case manualHandlingRequired(DeeplinkTokenType, token: String)
    }

    enum DeeplinkTokenType: String {
        case magicLinks = "magic_links"
        case oauth
        case passwordReset = "reset_password"
    }
}
