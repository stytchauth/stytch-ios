extension LocalStorage {
    private enum OrganizationStorageKey: LocalStorageKey {
        typealias Value = Organization
    }

    var organization: Organization? {
        get { Current.localStorage[OrganizationStorageKey.self] }
        set { Current.localStorage[OrganizationStorageKey.self] = newValue }
    }
}

extension LocalStorage {
    private enum MemberStorageKey: LocalStorageKey {
        typealias Value = Member
    }

    var member: Member? {
        get { Current.localStorage[MemberStorageKey.self] }
        set { Current.localStorage[MemberStorageKey.self] = newValue }
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
