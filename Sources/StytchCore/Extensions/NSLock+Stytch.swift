import Foundation

extension NSLock {
    func withLock<T>(perform: () -> T) -> T {
        lock()
        defer { unlock() }
        return perform()
    }
}
