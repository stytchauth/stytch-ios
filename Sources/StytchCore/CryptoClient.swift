import CommonCrypto
import CryptoKit
import Foundation

struct CryptoClient {
    func sha256(_ value: String) -> String {
        let data = Data(value.utf8)
        let toHexString: (inout String, CVarArg) -> Void = { $0 += String(format: "%02x", $1) }
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            return SHA256.hash(data: data).reduce(into: "", toHexString)
        } else {
            return data.withUnsafeBytes { buffer in
                var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
                CC_SHA256(buffer.baseAddress, UInt32(buffer.count), &hash)
                return Data(hash).reduce(into: "", toHexString)
            }
        }
    }
}
