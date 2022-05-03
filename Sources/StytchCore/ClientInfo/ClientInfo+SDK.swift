import Foundation

extension ClientInfo {
    struct SDK: Encodable {
        let identifier: String = "stytch-swift"
        let version: Version = .init(major: 0, minor: 0, patch: 1)
    }
}
