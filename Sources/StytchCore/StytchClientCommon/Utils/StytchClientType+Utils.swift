internal class UtilsImpl: Utils {
    private let keychainClient: KeychainClient

    init(keychainClient: KeychainClient) {
        self.keychainClient = keychainClient
    }

    func getPKCEPair() -> PKCEPair {
        let codeChallenge = try? keychainClient.get(.codeChallengePKCE)
        let codeVerifier = try? keychainClient.get(.codeVerifierPKCE)
        return PKCEPair(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
    }
}
