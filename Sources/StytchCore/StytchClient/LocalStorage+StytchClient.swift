extension LocalStorage {
    private enum UserStorageKey: LocalStorageKey {
        typealias Value = User
    }

    var user: User? {
        get { self[UserStorageKey.self] }
        set { self[UserStorageKey.self] = newValue }
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

extension LocalStorage {
    private enum BootstrapDataStorageKey: LocalStorageKey {
        typealias Value = BootstrapResponseData
    }
    
    var bootstrapData: BootstrapResponseData? {
        get { self[BootstrapDataStorageKey.self] }
        set { self[BootstrapDataStorageKey.self] = newValue}
    }
}
