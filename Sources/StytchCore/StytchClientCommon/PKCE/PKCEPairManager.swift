public struct PKCECodePair {
    let codeChallenge: String
    let codeVerifier: String
    let method: String

    init(codeChallenge: String, codeVerifier: String, method: String = "S256") {
        self.codeChallenge = codeChallenge
        self.codeVerifier = codeVerifier
        self.method = method
    }
}

protocol PKCEPairManager {
    // Generates a new code_verifier and stores the value in the keychain. Returns a hashed version of the code_verifier value along with a string representing the hash method (currently S256.)
    func generateAndReturnPKCECodePair() throws -> PKCECodePair

    func getPKCECodePair() -> PKCECodePair?

    func clearPKCECodePair() throws
}

internal class PKCEPairManagerImpl: PKCEPairManager {
    let keychainClient: KeychainClient
    let cryptoClient: CryptoClient

    init(keychainClient: KeychainClient, cryptoClient: CryptoClient) {
        self.keychainClient = keychainClient
        self.cryptoClient = cryptoClient
    }

    func generateAndReturnPKCECodePair() throws -> PKCECodePair {
        let codeVerifier = try cryptoClient.dataWithRandomBytesOfCount(32).toHexString()
        let codeChallenge = cryptoClient.sha256(codeVerifier).base64UrlEncoded()
        try keychainClient.set(codeVerifier, for: .codeVerifierPKCE)
        try keychainClient.set(codeChallenge, for: .codeChallengePKCE)
        return PKCECodePair(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
    }

    func getPKCECodePair() -> PKCECodePair? {
        let codeChallenge = try? keychainClient.get(.codeChallengePKCE)
        let codeVerifier = try? keychainClient.get(.codeVerifierPKCE)
        if let codeChallenge = codeChallenge, let codeVerifier = codeVerifier {
            return PKCECodePair(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
        } else {
            return nil
        }
    }

    func clearPKCECodePair() throws {
        try keychainClient.removeItem(.codeChallengePKCE)
        try keychainClient.removeItem(.codeVerifierPKCE)
    }
}
