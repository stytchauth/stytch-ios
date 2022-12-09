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
