import Foundation

struct Atomic<T> {
    private let lock: NSLock = .init()

    var value: T {
        get { withLock { _value } }
        set { withLock { _value = newValue } }
    }

    private var _value: T

    init(value: T) {
        self._value = value
    }

    private func withLock<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }
}
