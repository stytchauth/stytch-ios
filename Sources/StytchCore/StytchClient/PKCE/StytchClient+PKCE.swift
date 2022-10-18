import CommonCrypto
import CryptoKit

extension StytchClient {
    /// Generates a new code_verifier and stores the value in the keychain. Returns a hashed version of the code_verifier value along with a string representing the hash method (currently S256.)
    static func generateAndStorePKCE(keychainItem: KeychainClient.Item) throws -> (challenge: String, method: String) {
        let codeVerifier = try Current.cryptoClient.dataWithRandomBytesOfCount(32).toHexString()

        try Current.keychainClient.set(codeVerifier, for: keychainItem)

        return (Current.cryptoClient.sha256(codeVerifier).base64UrlEncoded(), "S256")
    }
}
