struct UserStorageKey: LocalStorageKey {
    typealias Value = User
}

extension LocalStorage {
    var user: User? {
        get { Current.localStorage[UserStorageKey.self] }
        set { Current.localStorage[UserStorageKey.self] = newValue }
    }
}
