import Combine
import Foundation

protocol StytchClientType {
    associatedtype DeeplinkResponse
    associatedtype DeeplinkTokenType
    associatedtype DeeplinkRedirectType

    static var instance: Self { get set }

    static var isInitialized: AnyPublisher<Bool, Never> { get }

    static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType, DeeplinkRedirectType>

    func start()
}

extension StytchClientType {
    private static var keychainClient: KeychainClient { Current.keychainClient }

    var configuration: Configuration? {
        get {
            localStorage.configuration
        }
        set {
            localStorage.configuration = newValue
            updateNetworkingClient()
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

    #if os(iOS)
    private var dfpClient: DFPProvider { Current.dfpClient }
    private var captchaClient: CaptchaProvider { Current.captcha }
    #endif

    var pkcePairManager: PKCEPairManager { Current.pkcePairManager }

    // swiftlint:disable:next type_contents_order
    mutating func configure(publicToken: String, hostUrl: URL?, dfppaDomain: String?) {
        configuration = .init(publicToken: publicToken, hostUrl: hostUrl, dfppaDomain: dfppaDomain)

        updateNetworkingClient()
        resetKeychainOnFreshInstall()
        runKeychainMigrations()
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            // only run this in non-test environments
            start()
        }
    }

    // swiftlint:disable:next identifier_name large_tuple
    static func _tokenValues(for url: URL) throws -> (tokenType: String, redirectType: String?, token: String)? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let typeQuery = queryItems.first(where: { $0.name == "stytch_token_type" }), let type = typeQuery.value,
            let redirectTypeQuery = queryItems.first(where: { $0.name == "stytch_redirect_type" }), let redirectType = redirectTypeQuery.value,
            let tokenQuery = queryItems.first(where: { $0.name == "token" }), let token = tokenQuery.value
        else {
            return nil
        }
        return (tokenType: type, redirectType, token)
    }

    // To be called after configuration
    private func updateNetworkingClient() {
        let clientInfoString = try? clientInfo.base64EncodedString(encoder: jsonEncoder)

        networkingClient.headerProvider = { [weak localStorage, weak sessionManager] in
            guard let configuration = localStorage?.configuration else { return [:] }
            let sessionToken = sessionManager?.sessionToken?.value ?? configuration.publicToken
            let authToken = "\(configuration.publicToken):\(sessionToken)".base64Encoded()

            return [
                "Content-Type": "application/json",
                "Authorization": "Basic \(authToken)",
                "X-SDK-Client": clientInfoString ?? "",
            ]
        }
        networkingClient.publicToken = configuration?.publicToken ?? ""
        networkingClient.dfppaDomain = configuration?.dfppaDomain ?? ""
    }

    private func resetKeychainOnFreshInstall() {
        guard
            case let installIdDefaultsKey = "stytch_install_id_defaults_key",
            defaults.string(forKey: installIdDefaultsKey) == nil
        else { return }

        defaults.set(uuid().uuidString, forKey: installIdDefaultsKey)
        KeychainClient.Item.allItems.forEach { item in
            try? keychainClient.removeItem(item)
        }
    }

    private func runKeychainMigrations() {
        KeychainClient.migrations.forEach { migration in
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
}
