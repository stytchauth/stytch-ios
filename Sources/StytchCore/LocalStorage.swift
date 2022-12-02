import Foundation

protocol LocalStorageKey<Value>: Sendable {
    associatedtype Value: Sendable
}

struct LocalStorage {
    static var instance: Self = .init()

    private var storage: [ObjectIdentifier: Any] = [:]

    private let lock: NSLock = .init()

    private init() {}

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
