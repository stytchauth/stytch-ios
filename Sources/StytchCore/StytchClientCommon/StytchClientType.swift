import Foundation

protocol StytchClientType {
    associatedtype AuthResponseType: Decodable

    static var instance: Self { get set }

    static func handle(url: URL, sessionDuration: Minutes) async throws -> DeeplinkHandledStatus<AuthResponseType>
}

extension StytchClientType {
    var configuration: Configuration? {
        get { Current.localStorage.configuration }
        set {
            Current.localStorage.configuration = newValue
            updateHeaderProvider()
        }
    }

    mutating func postInit() {
        guard
            let url = Bundle.main.url(forResource: "StytchConfiguration", withExtension: "plist"),
            let data = try? Data(contentsOf: url)
        else { return }

        self.configuration = try? PropertyListDecoder().decode(Configuration.self, from: data)

        updateHeaderProvider()
        runKeychainMigrations()
    }

    static func _configure(publicToken: String, hostUrl: URL? = nil) {
        instance.configuration = .init(publicToken: publicToken, hostUrl: hostUrl)
    }

    static func _tokenValues(for url: URL) throws -> (DeeplinkTokenType, String)? {
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

    // Generates a new code_verifier and stores the value in the keychain. Returns a hashed version of the code_verifier value along with a string representing the hash method (currently S256.)
    static func generateAndStorePKCE(keychainItem: KeychainClient.Item) throws -> (challenge: String, method: String) {
        let codeVerifier = try Current.cryptoClient.dataWithRandomBytesOfCount(32).toHexString()

        try Current.keychainClient.set(codeVerifier, for: keychainItem)

        return (Current.cryptoClient.sha256(codeVerifier).base64UrlEncoded(), "S256")
    }

    // To be called after configuration
    private func updateHeaderProvider() {
        let clientInfoString = try? Current.clientInfo.base64EncodedString()

        Current.networkingClient.headerProvider = { [weak localStorage = Current.localStorage] in
            guard let configuration = localStorage?.configuration else { return [:] }

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

private extension LocalStorage {
    private enum ConfigurationLocalStorageKey: LocalStorageKey {
        typealias Value = Configuration
    }

    var configuration: Configuration? {
        get { Current.localStorage[ConfigurationLocalStorageKey.self] }
        set { Current.localStorage[ConfigurationLocalStorageKey.self] = newValue }
    }
}
