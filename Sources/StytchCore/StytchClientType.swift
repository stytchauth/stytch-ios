import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

protocol StytchClientType {
    associatedtype DeeplinkResponse
    associatedtype DeeplinkTokenType
    associatedtype DeeplinkRedirectType

    static var instance: Self { get set }
    static var clientType: ClientType { get }

    static var isInitialized: AnyPublisher<Bool, Never> { get }

    static func handle(url: URL, sessionDurationMinutes: Minutes) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType>
}

extension StytchClientType {
    private static var keychainClient: KeychainClient { Current.keychainClient }

    var configuration: StytchClientConfiguration? {
        get {
            localStorage.configuration
        }
        set {
            localStorage.configuration = newValue
        }
    }

    var sessionManager: SessionManager { Current.sessionManager }

    var localStorage: LocalStorage { Current.localStorage }

    private var keychainClient: KeychainClient { Current.keychainClient }

    private var networkingClient: NetworkingClient { Current.networkingClient }

    private var defaults: UserDefaults { Current.defaults }

    private var jsonEncoder: JSONEncoder { Current.jsonEncoder }

    private var clientInfo: ClientInfo { Current.clientInfo }

    private var uuid: () -> UUID { Current.uuid }

    var pkcePairManager: PKCEPairManager { Current.pkcePairManager }

    // swiftlint:disable:next type_contents_order
    mutating func configure(newConfiguration: StytchClientConfiguration) {
        guard newConfiguration != configuration else {
            return
        }

        configuration = newConfiguration

        resetKeychainOnFreshInstall()
        runKeychainMigrations()
        sessionManager.clearEmptyTokens()

        #if canImport(StytchDFP)
        if let publicToken = configuration?.publicToken {
            Current.dfpClient.configure(publicToken: publicToken, dfppaDomain: configuration?.dfppaDomain)
        }
        #endif

        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            // only run this in non-test environments
            start()
        }
    }

    // swiftlint:disable:next type_contents_order
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
        if UIApplication.shared.isProtectedDataAvailable {
            keychainClient.onProtectedDataDidBecomeAvailable()
            defaultStartupFlow()
        } else {
            NotificationCenter.default.addObserver(forName: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil, queue: nil) { _ in
                keychainClient.onProtectedDataDidBecomeAvailable()
                defaultStartupFlow()
            }
        }
        #else
        defaultStartupFlow()
        #endif
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
            defaults.string(forKey: installIdDefaultsKey) == nil
        else { return }

        defaults.set(uuid().uuidString, forKey: installIdDefaultsKey)
        KeychainItem.allItems.forEach { item in
            try? keychainClient.removeItem(item: item)
        }
    }

    private func runKeychainMigrations() {
        keychainClient.migrations().forEach { migration in
            let migrationName = "stytch_keychain_migration_" + String(describing: migration.self)
            guard !defaults.bool(forKey: migrationName) else {
                return
            }
            do {
                try migration.run()
                defaults.set(true, forKey: migrationName)
            } catch {
                print(error)
            }
        }
    }

    private func defaultStartupFlow() {
        Task {
            do {
                try await StartupClient.start(clientType: Self.clientType)
                try? await EventsClient.logEvent(parameters: .init(eventName: "client_initialization_success"))
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "client_initialization_failure"))
            }
        }
    }
}
