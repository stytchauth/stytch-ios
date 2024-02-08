import Combine
import Foundation

final class UserStorage {
    private(set) var user: User? {
        get { localStorage.user }
        set { localStorage.user = newValue }
    }

    private(set) lazy var onUserChange = _onUserChange
        .map { [weak self] in self?.user == nil }
        .removeDuplicates()
        .map { [weak self] _ in self?.user }

    private let _onUserChange = PassthroughSubject<Void, Never>()

    @Dependency(\.localStorage) private var localStorage

    func updateUser(_ user: User) {
        self.user = user
        _onUserChange.send(())
    }

    func reset() {
        user = nil
        _onUserChange.send(())
    }
}
