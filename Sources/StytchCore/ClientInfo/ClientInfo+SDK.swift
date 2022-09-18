import Foundation

extension ClientInfo {
    struct SDK: Encodable {
        let identifier: String = "stytch-swift"
        let version: Version = .current
    }
}
