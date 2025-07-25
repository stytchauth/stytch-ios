/// A data class representing the most recent PKCE code pair generated on this device. You may find this useful if you
/// use a hybrid (frontend and backend) authentication flow, where you need to complete a PKCE flow on the backend
public struct PKCECodePair: Sendable {
    let codeChallenge: String
    let codeVerifier: String
    let method: String

    /// - Parameters:
    ///   - codeChallenge: the challenge that was generated
    ///   - codeVerifier: the verifier of the challenge
    ///   - method: a string identifying the encryption method used. This will always be "S256"
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
    let userDefaultsClient: EncryptedUserDefaultsClient
    let cryptoClient: CryptoClient

    init(userDefaultsClient: EncryptedUserDefaultsClient, cryptoClient: CryptoClient) {
        self.userDefaultsClient = userDefaultsClient
        self.cryptoClient = cryptoClient
    }

    func generateAndReturnPKCECodePair() throws -> PKCECodePair {
        let codeVerifier = try cryptoClient.dataWithRandomBytesOfCount(32).toHexString()
        let codeChallenge = cryptoClient.sha256(codeVerifier).base64UrlEncoded()
        try userDefaultsClient.setStringValue(codeVerifier, for: .codeVerifierPKCE)
        try userDefaultsClient.setStringValue(codeChallenge, for: .codeChallengePKCE)
        return PKCECodePair(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
    }

    func getPKCECodePair() -> PKCECodePair? {
        let codeChallenge = try? userDefaultsClient.getStringValue(.codeChallengePKCE)
        let codeVerifier = try? userDefaultsClient.getStringValue(.codeVerifierPKCE)
        if let codeChallenge = codeChallenge, let codeVerifier = codeVerifier {
            return PKCECodePair(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
        } else {
            return nil
        }
    }

    func clearPKCECodePair() throws {
        try userDefaultsClient.removeItem(item: .codeChallengePKCE)
        try userDefaultsClient.removeItem(item: .codeVerifierPKCE)
    }
}
