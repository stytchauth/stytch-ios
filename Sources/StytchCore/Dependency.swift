@propertyWrapper
struct Dependency<T> {
    var wrappedValue: T {
        Current[keyPath: keyPath]
    }

    private let keyPath: KeyPath<Environment, T>

    init(_ keyPath: KeyPath<Environment, T>) {
        self.keyPath = keyPath
    }
}
