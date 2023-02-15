
extension LocalStorage {
    private enum MemberSessionStorageKey: LocalStorageKey {
        typealias Value = MemberSession
    }

    var memberSession: MemberSession? {
        get { self[MemberSessionStorageKey.self] }
        set { self[MemberSessionStorageKey.self] = newValue }
    }
}
