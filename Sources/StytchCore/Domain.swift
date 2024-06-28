import Foundation

extension LocalStorage {
    func stytchDomain(_ publicToken: String) -> String {
        let domain: String
        if let cnameDomain = bootstrapData?.cnameDomain {
            domain = cnameDomain
        } else if publicToken.hasPrefix("public-token-test") {
            domain = "test.stytch.com"
        } else {
            domain = "api.stytch.com"
        }
        return domain
    }
}
