import CommonCrypto
import CryptoKit
import Foundation

extension StytchClient {
    /// Generates a new code_verifier and stores the value in the keychain. Then hashes the value and returns the hashed value along with a string representing the hash method. (Currently sha256)
    static func generateAndStorePKCE() throws -> (challenge: String, method: String) {
        let codeVerifier = Current.uuid().uuidString

        try Current.keychainClient.set(codeVerifier, for: .stytchPKCECodeVerifier)

        return (Current.cryptoClient.sha256(codeVerifier).base64Encoded(), "S256")
    }

    /// Wraps an `authenticate` ``Completion`` and removes the PKCE code verifier from persistent storage upon success.
    static func pckeAuthenticateCompletion<T>(_ completion: @escaping Completion<T>) -> Completion<T> {
        { result in
            if case .success = result {
                try? Current.keychainClient.remove(.stytchPKCECodeVerifier)
            }
            completion(result)
        }
    }
}
