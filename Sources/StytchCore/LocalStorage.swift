import Foundation

protocol LocalStorageKey<Value>: Sendable {
    associatedtype Value: Sendable
}

final class LocalStorage {
    static var instance: LocalStorage = .init()

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
