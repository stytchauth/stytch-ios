import Foundation

struct CryptoClient {
    var sha256: (String) -> Data
    var dataWithRandomBytesOfCount: (UInt) throws -> Data
    var generateKeyPair: () -> (privateKey: Data, publicKey: Data)
    var publicKeyForPrivateKey: (Data) throws -> Data
    var signChallengeWithPrivateKey: (Data, Data) throws -> Data
}
