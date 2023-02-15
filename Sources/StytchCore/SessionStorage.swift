import Foundation

final class SessionStorage {
    var activeSessionExists: Bool {
        (sessionJwt ?? sessionToken) != nil
    }

    private(set) var sessionToken: SessionToken? {
        get {
            try? Current.keychainClient.get(.sessionToken).map(SessionToken.opaque)
        }
        set {
            let keychainItem: KeychainClient.Item = .sessionToken
            if let newValue = newValue {
                try? Current.keychainClient.set(newValue.value, for: keychainItem)
            } else {
                try? Current.keychainClient.removeItem(keychainItem)
                Current.cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var sessionJwt: SessionToken? {
        get {
            try? Current.keychainClient.get(.sessionJwt).map(SessionToken.jwt)
        }
        set {
            let keychainItem: KeychainClient.Item = .sessionJwt
            if let newValue = newValue {
                try? Current.keychainClient.set(newValue.value, for: keychainItem)
            } else {
                try? Current.keychainClient.removeItem(keychainItem)
                Current.cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var session: Session? {
        get { Current.localStorage.session }
        set { Current.localStorage.session = newValue }
    }

    init() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(cookiesDidUpdate(notification:)),
                name: .NSHTTPCookieManagerCookiesChanged,
                object: nil
            )
    }

    func updateSession(_ session: Session, tokens: [Session.Token], hostUrl: URL?) {
        self.session = session
        tokens.forEach { token in
            updatePersistentStorage(token: token)

            if let cookie = cookieFor(token: token, expiresAt: session.expiresAt, hostUrl: hostUrl) {
                Current.cookieClient.set(cookie: cookie)
            }
        }
        Current.sessionsPollingClient.start()
    }

    func updatePersistentStorage(token: SessionToken) {
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
        SessionToken.Kind.allCases
            .map(\.name)
            .forEach(Current.cookieClient.deleteCookie(named:))
        Current.sessionsPollingClient.stop()
    }

    @objc
    func cookiesDidUpdate(notification: Notification) {
        let storage = notification.object as? HTTPCookieStorage ?? .shared

        guard let cookies = storage.cookies else { return }

        cookies
            .filter { SessionToken.Kind.allCases.map(\.name).contains($0.name) }
            .compactMap { cookie in
                // If the cookie is expired, discard the cookie/value
                if let expiresAt = cookie.expiresDate, expiresAt <= Current.date() {
                    return nil
                }

                switch cookie.name {
                case SessionToken.Kind.jwt.name:
                    return .jwt(cookie.value)
                case SessionToken.Kind.opaque.name:
                    return .opaque(cookie.value)
                default:
                    return nil
                }
            }
            .forEach(updatePersistentStorage(token:))
    }

    private func cookieFor(token: SessionToken, expiresAt: Date, hostUrl: URL?) -> HTTPCookie? {
        guard let hostUrl, let urlComponents = URLComponents(url: hostUrl, resolvingAgainstBaseURL: true) else { return nil }

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
}
