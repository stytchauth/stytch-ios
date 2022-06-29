import Foundation

final class SessionStorage {
    private(set) var sessionToken: Session.Token? {
        get {
            withLock(keychainLock) {
                try? Current.keychainClient.get(.sessionToken).map(Session.Token.opaque)
            }
        }
        set {
            withLock(keychainLock) {
                let keychainItem: KeychainClient.Item = .sessionToken
                if let newValue = newValue {
                    try? Current.keychainClient.set(newValue.value, for: keychainItem)
                } else {
                    try? Current.keychainClient.remove(keychainItem)
                    Current.cookieClient.deleteCookie(named: keychainItem.name)
                }
            }
        }
    }

    private(set) var sessionJwt: Session.Token? {
        get {
            withLock(keychainLock) {
                try? Current.keychainClient.get(.sessionJwt).map(Session.Token.jwt)
            }
        }
        set {
            withLock(keychainLock) {
                let keychainItem: KeychainClient.Item = .sessionJwt
                if let newValue = newValue {
                    try? Current.keychainClient.set(newValue.value, for: keychainItem)
                } else {
                    try? Current.keychainClient.remove(keychainItem)
                    Current.cookieClient.deleteCookie(named: keychainItem.name)
                }
            }
        }
    }

    // TODO: persist the session
    private(set) var session: Session?

    private let keychainLock: NSLock = .init()

    init() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(cookiesDidUpdate(notification:)),
                name: .NSHTTPCookieManagerCookiesChanged,
                object: nil
            )
    }

    func updateSession(_ session: Session, tokens: [Session.Token], hostUrl: URL) {
        self.session = session
        tokens.forEach { token in
            updatePersistentStorage(token: token)

            if let cookie = cookieFor(token: token, expiresAt: session.expiresAt, hostUrl: hostUrl) {
                Current.cookieClient.set(cookie: cookie)
            }
        }
        Current.sessionsPollingClient.start()
    }

    func updatePersistentStorage(token: Session.Token) {
        switch token.kind {
        case .jwt:
            sessionJwt = token
        case .opaque:
            sessionToken = token
        }
    }

    func reset() {
        session = nil
        sessionToken = nil
        sessionJwt = nil
        Session.Token.Kind.allCases
            .map(\.name)
            .forEach(Current.cookieClient.deleteCookie(named:))
        Current.sessionsPollingClient.stop()
    }

    @objc
    func cookiesDidUpdate(notification: Notification) {
        let storage = notification.object as? HTTPCookieStorage ?? .shared

        guard let cookies = storage.cookies else { return }

        cookies
            .filter { Session.Token.Kind.allCases.map(\.name).contains($0.name) }
            .compactMap { cookie in
                // If the cookie is expired, discard the cookie/value
                if let expiresAt = cookie.expiresDate, expiresAt <= Current.date() {
                    return nil
                }

                switch cookie.name {
                case Session.Token.Kind.jwt.name:
                    return .jwt(cookie.value)
                case Session.Token.Kind.opaque.name:
                    return .opaque(cookie.value)
                default:
                    return nil
                }
            }
            .forEach(updatePersistentStorage(token:))
    }

    private func cookieFor(token: Session.Token, expiresAt: Date, hostUrl: URL) -> HTTPCookie? {
        guard let urlComponents = URLComponents(url: hostUrl, resolvingAgainstBaseURL: true) else { return nil }

        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: token.name,
            .value: token.value,
            .path: "/",
            .domain: hostUrl.host ?? hostUrl.absoluteString,
            .expires: expiresAt,
            .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
        ]
        if !urlComponents.isLocalHost {
            properties[.secure] = true
        }

        return HTTPCookie(properties: properties)
    }

    private func withLock<T>(_ lock: NSLock, perform: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return perform()
    }
}

private extension KeychainClient.Item {
    static let sessionToken: Self = .init(kind: .token, name: Session.Token.Kind.opaque.name)
    static let sessionJwt: Self = .init(kind: .token, name: Session.Token.Kind.jwt.name)
}
