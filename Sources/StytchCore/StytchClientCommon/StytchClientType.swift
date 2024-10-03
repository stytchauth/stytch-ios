import Combine
import Foundation

protocol StytchClientType {
    associatedtype DeeplinkResponse
    associatedtype DeeplinkTokenType

    static var instance: Self { get set }

    static var isInitialized: AnyPublisher<Bool, Never> { get }

    static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType>

    func runBootstrapping()
}

extension StytchClientType {
    private static var keychainClient: KeychainClient { Current.keychainClient }

    var configuration: Configuration? {
        get { localStorage.configuration }
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

    /// An instance of `InitializationState` that wraps a publisher `isInitialized` that alerts the caller when the bootstrap call has completed successfully.
    /// NOTE: It does not represent if the Stytch iOS SDK is ready to use or not. That is currently solely determined by the SDK having a valid public token.
    public var initializationState: InitializationState { Current.initializationState }

    // swiftlint:disable:next identifier_name
    static func _configure(publicToken: String, hostUrl: URL? = nil, dfppaDomain: String? = nil) {
        instance.configuration = .init(publicToken: publicToken, hostUrl: hostUrl, dfppaDomain: dfppaDomain)
    }

    // swiftlint:disable:next identifier_name
    static func _tokenValues(for url: URL) throws -> (tokenType: String, token: String)? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let typeQuery = queryItems.first(where: { $0.name == "stytch_token_type" }), let type = typeQuery.value,
            let tokenQuery = queryItems.first(where: { $0.name == "token" }), let token = tokenQuery.value
        else {
            return nil
        }
        return (tokenType: type, token)
    }

    mutating func postInit() {
        if let url = Bundle.main.url(forResource: "StytchConfiguration", withExtension: "plist"), let data = try? Data(contentsOf: url) {
            configuration = try? PropertyListDecoder().decode(Configuration.self, from: data)
        }

        updateNetworkingClient()
        resetKeychainOnFreshInstall()
        runKeychainMigrations()
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            // only run this in non-test environments
            runBootstrapping()
        }

        publishCachedValuesIfNeededForStartup()
    }

    // TODO: We should remove this and make "publish" private within ObjectStorage
    private func publishCachedValuesIfNeededForStartup() {
        Current.sessionStorage.publish()
        Current.memberSessionStorage.publish()
        Current.userStorage.publish()
        Current.memberStorage.publish()
        Current.organizationStorage.publish()
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
