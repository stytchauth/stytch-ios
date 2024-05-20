import Combine
import Foundation

final class MemberStorage {
    private(set) var member: Member? {
        get { localStorage.member }
        set { localStorage.member = newValue }
    }

    private(set) lazy var onMemberChange = _onMemberChange
        .map { [weak self] in self?.member == nil }
        .removeDuplicates()
        .map { [weak self] _ in self?.member }

    private let _onMemberChange = PassthroughSubject<Void, Never>()

    @Dependency(\.localStorage) private var localStorage

    func updateMember(_ member: Member) {
        self.member = member
        _onMemberChange.send(())
    }

    func reset() {
        member = nil
        _onMemberChange.send(())
    }
}
