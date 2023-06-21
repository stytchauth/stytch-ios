import Foundation

extension ClientInfo {
    struct SDK: Encodable {
        let identifier: String = "stytch-ios"
        let version: Version = .current
    }
}
