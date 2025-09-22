import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

// swiftlint:disable type_contents_order

/*
 StytchClientCommonInternal and StytchClientCommonPublic could effectively be merged into
 a single type since both conceptually exist to define the shared functionality between
 StytchClient and StytchB2BClient. However, we need some functionality to be internal and
 some to be public. For that reason, StytchClientCommonInternal represents the internal
 shared functionality while StytchClientCommonPublic defines the public shared functionality.

 StytchClientCommonInternal inherits from StytchClientCommonPublic so that all conformance
 to both protocols for the clients is handled through StytchClientCommonInternal.
 */

public protocol StytchClientCommonPublic {}

protocol StytchClientCommonInternal: StytchClientCommonPublic {
    associatedtype DeeplinkResponse
    associatedtype DeeplinkTokenType
    associatedtype DeeplinkRedirectType

    static var shared: Self { get }
    static var clientType: ClientType { get }

    static var isInitialized: AnyPublisher<Bool, Never> { get }

    static func handle(url: URL, sessionDurationMinutes: Minutes) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType>
}

extension StytchClientCommonInternal {
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    mutating func configure(newConfiguration: StytchClientConfiguration) {
        guard newConfiguration != Self.stytchClientConfiguration else {
            return
        }

        Current.localStorage.stytchClientConfiguration = newConfiguration

        resetKeychainOnFreshInstall()
        runKeychainMigrations()
        Current.sessionManager.clearEmptyTokens()

        #if canImport(StytchDFP)
        if let publicToken = Self.stytchClientConfiguration?.publicToken {
            Current.dfpClient.configure(publicToken: publicToken, dfppaDomain: Self.stytchClientConfiguration?.dfppaDomain)
        }
        #endif

        if isRunningTests == false {
            start()
        }
    }

    func start() {
        #if os(iOS)
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { _ in
            Task {
                // Skip the startup sequence if offline, it will auto-start when connectivity is restored.
                if Current.networkMonitor.isConnected == true {
                    try await StartupClient.start(clientType: Self.clientType)
                }
            }
        }
        #endif

        Task {
            do {
                try await StartupClient.start(clientType: Self.clientType)
                try? await EventsClient.logEvent(parameters: .init(eventName: "client_initialization_success"))
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "client_initialization_failure"))
            }
        }
    }

    // swiftlint:disable:next identifier_name large_tuple
    static func _tokenValues(for url: URL) throws -> (tokenType: String, redirectType: String?, token: String)? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let typeQuery = queryItems.first(where: { $0.name == "stytch_token_type" }), let type = typeQuery.value,
            let tokenQuery = queryItems.first(where: { $0.name == "token" }), let token = tokenQuery.value
        else {
            return nil
        }

        var redirectType: String?
        if let redirectTypeQuery = queryItems.first(where: { $0.name == "stytch_redirect_type" }) {
            redirectType = redirectTypeQuery.value
        }

        return (tokenType: type, redirectType, token)
    }

    private func resetKeychainOnFreshInstall() {
        guard
            case let installIdDefaultsKey = "stytch_install_id_defaults_key",
            Current.defaults.string(forKey: installIdDefaultsKey) == nil
        else { return }

        Current.defaults.set(Current.uuid().uuidString, forKey: installIdDefaultsKey)
        KeychainItem.allItems.forEach { item in
            try? Current.keychainClient.removeItem(item: item)
        }
    }

    private func runKeychainMigrations() {
        Current.keychainClient.migrations().forEach { migration in
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

public extension StytchClientCommonPublic {
    /**
     Signals that the SDK is fully initialized and ready for use.
     This is sent after two parallel tasks complete:
     1. Attempting to call sessions.authenticate (if there's a session token cached on the device).
     2. Bootstrapping configuration, including DFP and captcha setup.
     */
    static var isInitialized: AnyPublisher<Bool, Never> {
        StartupClient.isInitialized
    }

    /// The active client configuration, persisted in local storage.
    static var stytchClientConfiguration: StytchClientConfiguration? {
        Current.localStorage.stytchClientConfiguration
    }

    /// The most recent bootstrap payload from the backend
    static var bootstrapData: BootstrapResponseData? {
        Current.localStorage.bootstrapData
    }

    /// Retrieve the most recently created PKCE code pair from the device, if available
    static func getPKCECodePair() -> PKCECodePair? {
        Current.pkcePairManager.getPKCECodePair()
    }

    /// The default session duration in minutes used by authentication calls when a per call value is not provided.
    /// If the client configuration specifies a value, that value is returned.
    /// Defaults to 5.
    static var defaultSessionDuration: Minutes {
        if let defaultSessionDuration = stytchClientConfiguration?.defaultSessionDuration {
            return defaultSessionDuration
        } else {
            return 5
        }
    }
}
