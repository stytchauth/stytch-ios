import Foundation

protocol LocalStorageKey<Value>: Sendable {
    associatedtype Value: Sendable
}

final class LocalStorage {
    private var storage: [ObjectIdentifier: Any] = [:]

    private let lock: NSLock = .init()

    subscript<T: LocalStorageKey>(storageKey: T.Type) -> T.Value? {
        get {
            lock.withLock {
                storage[ObjectIdentifier(storageKey)] as? T.Value
            }
        }
        set {
            lock.withLock {
                storage[ObjectIdentifier(storageKey)] = newValue
            }
        }
    }
}

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

extension LocalStorage {
    private enum BootstrapDataStorageKey: LocalStorageKey {
        typealias Value = BootstrapResponseData
    }

    var bootstrapData: BootstrapResponseData? {
        get { self[BootstrapDataStorageKey.self] }
        set { self[BootstrapDataStorageKey.self] = newValue }
    }
}

extension LocalStorage {
    private enum ConfigurationStorageKey: LocalStorageKey {
        typealias Value = Configuration
    }

    var configuration: Configuration? {
        get { self[ConfigurationStorageKey.self] }
        set { self[ConfigurationStorageKey.self] = newValue }
    }
}
