import CryptoKit
import Foundation

extension CryptoClient {
    static let live: Self = .init { value in
        .init(SHA256.hash(data: Data(value.utf8)))
    } dataWithRandomBytesOfCount: { byteCount in
        var buffer = [UInt8](repeating: 0, count: Int(byteCount))

        guard SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer) == errSecSuccess else {
            throw StytchError.randomNumberGenerationFailed
        }

        return .init(buffer)
    } generateKeyPair: {
        let privateKey = Curve25519.Signing.PrivateKey()
        return (
            privateKey.rawRepresentation,
            privateKey.publicKey.rawRepresentation
        )
    } publicKeyForPrivateKey: { privateKeyData in
        try Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyData)
            .publicKey
            .rawRepresentation
    } signChallengeWithPrivateKey: { challenge, privateKeyData in
        try Curve25519.Signing.PrivateKey(rawRepresentation: privateKeyData)
            .signature(for: challenge)
    }
}
