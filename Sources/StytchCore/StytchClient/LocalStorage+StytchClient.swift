extension LocalStorage {
    private enum UserStorageKey: LocalStorageKey {
        typealias Value = User
    }

    var user: User? {
        get { Current.localStorage[UserStorageKey.self] }
        set { Current.localStorage[UserStorageKey.self] = newValue }
    }
}

extension LocalStorage {
    private enum SessionStorageKey: LocalStorageKey {
        typealias Value = Session
    }

    var session: Session? {
        get { self[SessionStorageKey.self] }
        set { self[SessionStorageKey.self] = newValue }
    }
}

