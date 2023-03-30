extension LocalStorage {
    private enum OrganizationStorageKey: LocalStorageKey {
        typealias Value = Organization
    }

    var organization: Organization? {
        get { self[OrganizationStorageKey.self] }
        set { self[OrganizationStorageKey.self] = newValue }
    }
}

extension LocalStorage {
    private enum MemberStorageKey: LocalStorageKey {
        typealias Value = Member
    }

    var member: Member? {
        get { self[MemberStorageKey.self] }
        set { self[MemberStorageKey.self] = newValue }
    }
}

extension LocalStorage {
    private enum MemberSessionStorageKey: LocalStorageKey {
        typealias Value = MemberSession
    }

    var memberSession: MemberSession? {
        get { self[MemberSessionStorageKey.self] }
        set { self[MemberSessionStorageKey.self] = newValue }
    }
}
