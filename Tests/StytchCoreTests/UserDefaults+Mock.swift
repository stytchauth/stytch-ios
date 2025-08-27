import Foundation

private final class MockDefaults: UserDefaults, @unchecked Sendable {
    private var values: [String: Any] = [:]

    override func object(forKey defaultName: String) -> Any? {
        values[defaultName]
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        values[defaultName] = value
    }
}

extension UserDefaults {
    static func mock() -> UserDefaults {
        MockDefaults()
    }
}
