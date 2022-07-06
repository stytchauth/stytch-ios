import CommonCrypto
import CryptoKit
import Foundation

extension StytchClient {
    /// Generates a new code_verifier and stores the value in the keychain. Returns a hashed version of the code_verifier value along with a string representing the hash method (currently S256.)
    static func generateAndStorePKCE() throws -> (challenge: String, method: String) {
        let codeVerifier = try Current.cryptoClient.dataWithRandomBytesOfCount(32).toHexString()

        try Current.keychainClient.set(codeVerifier, for: .stytchPKCECodeVerifier)

        return (Current.cryptoClient.sha256(codeVerifier).base64UrlEncoded(), "S256")
    }

    /// Wraps an `authenticate` ``Completion`` and removes the PKCE code verifier from persistent storage upon success.
    static func pckeAuthenticateCompletion<T>(_ completion: @escaping Completion<T>) -> Completion<T> {
        { result in
            if case .success = result {
                try? Current.keychainClient.removeItem(.stytchPKCECodeVerifier)
            }
            completion(result)
        }
    }
}

private extension Data {
    func base64UrlEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
