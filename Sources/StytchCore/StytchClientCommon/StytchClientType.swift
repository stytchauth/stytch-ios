import Foundation

protocol StytchClientType {
    associatedtype DeeplinkResponse
    associatedtype DeeplinkTokenType

    static var instance: Self { get set }

    static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus<DeeplinkResponse, DeeplinkTokenType>
}

extension StytchClientType {
    private static var keychainClient: KeychainClient { Current.keychainClient }

    private static var cryptoClient: CryptoClient { Current.cryptoClient }

    var configuration: Configuration? {
        get { localStorage.configuration }
        set {
            localStorage.configuration = newValue
            updateNetworkingClient()
        }
    }

    private var sessionStorage: SessionStorage { Current.sessionStorage }

    private var localStorage: LocalStorage { Current.localStorage }

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

    // swiftlint:disable:next identifier_name
    static func _configure(publicToken: String, hostUrl: URL? = nil) {
        instance.configuration = .init(publicToken: publicToken, hostUrl: hostUrl)
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

    // Generates a new code_verifier and stores the value in the keychain. Returns a hashed version of the code_verifier value along with a string representing the hash method (currently S256.)
    static func generateAndStorePKCE(keychainItem: KeychainClient.Item) throws -> (challenge: String, method: String) {
        let codeVerifier = try cryptoClient.dataWithRandomBytesOfCount(32).toHexString()

        try keychainClient.set(codeVerifier, for: keychainItem)

        return (cryptoClient.sha256(codeVerifier).base64UrlEncoded(), "S256")
    }

    mutating func postInit() {
        if let url = Bundle.main.url(forResource: "StytchConfiguration", withExtension: "plist"), let data = try? Data(contentsOf: url) {
            configuration = try? PropertyListDecoder().decode(Configuration.self, from: data)
        }

        updateNetworkingClient()
        resetKeychainOnFreshInstall()
        runKeychainMigrations()
    }

    // To be called after configuration
    private func updateNetworkingClient() {
        let clientInfoString = try? clientInfo.base64EncodedString(encoder: jsonEncoder)

        networkingClient.headerProvider = { [weak localStorage, weak sessionStorage] in
            guard let configuration = localStorage?.configuration else { return [:] }

            let sessionToken = sessionStorage?.sessionToken?.value ?? configuration.publicToken
            let authToken = "\(configuration.publicToken):\(sessionToken)".base64Encoded()

            return [
                "Content-Type": "application/json",
                "Authorization": "Basic \(authToken)",
                "X-SDK-Client": clientInfoString ?? "",
            ]
        }
        networkingClient.publicToken = configuration?.publicToken ?? ""
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

private extension LocalStorage {
    private enum ConfigurationStorageKey: LocalStorageKey {
        typealias Value = Configuration
    }

    var configuration: Configuration? {
        get { self[ConfigurationStorageKey.self] }
        set { self[ConfigurationStorageKey.self] = newValue }
    }
}
