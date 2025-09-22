import Foundation

final class LocalStorage {
    private let lock: NSLock = .init()

    private var _bootstrapData: BootstrapResponseData?
    var bootstrapData: BootstrapResponseData? {
        get {
            lock.withLock {
                _bootstrapData
            }
        }
        set {
            lock.withLock {
                _bootstrapData = newValue
            }
        }
    }

    private var _stytchClientConfiguration: StytchClientConfiguration?
    var stytchClientConfiguration: StytchClientConfiguration? {
        get {
            lock.withLock {
                _stytchClientConfiguration
            }
        }
        set {
            lock.withLock {
                _stytchClientConfiguration = newValue
            }
        }
    }

    func stytchDomain(_ publicToken: String) -> String {
        let domain: String
        if let cnameDomain = bootstrapData?.cnameDomain {
            domain = cnameDomain
        } else if publicToken.hasPrefix("public-token-test") {
            domain = stytchClientConfiguration?.testDomain ?? "test.stytch.com"
        } else {
            domain = stytchClientConfiguration?.liveDomain ?? "api.stytch.com"
        }
        return domain
    }
}
