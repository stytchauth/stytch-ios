import CommonCrypto
import CryptoKit
import Foundation

struct CryptoClient {
    func sha256(_ value: String) -> Data {
        Data(value.utf8).withUnsafeBytes { buffer in
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(buffer.baseAddress, UInt32(buffer.count), &hash)
            return .init(hash)
        }
    }
}
