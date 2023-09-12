import Combine
import Foundation

final class SessionStorage {
    var activeSessionExists: Bool {
        (sessionJwt ?? sessionToken) != nil
    }

    private(set) lazy var onAuthChange = _onAuthChange
        .map { [weak self] in self?.sessionToken == nil }
        .removeDuplicates()
        .map { [weak self] _ in self?.sessionToken?.value }

    private let _onAuthChange = PassthroughSubject<Void, Never>()

    private(set) var sessionToken: SessionToken? {
        get {
            try? keychainClient.get(.sessionToken).map(SessionToken.opaque)
        }
        set {
            print("[DEBUG] >>> sessionToken setter called with \(newValue)")
            let keychainItem: KeychainClient.Item = .sessionToken
            if let newValue = newValue {
                try? keychainClient.set(newValue.value, for: keychainItem)
            } else {
                try? keychainClient.removeItem(keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var sessionJwt: SessionToken? {
        get {
            try? keychainClient.get(.sessionJwt).map(SessionToken.jwt)
        }
        set {
            print("[DEBUG] >>> sessionJwt setter called with \(newValue)")
            let keychainItem: KeychainClient.Item = .sessionJwt
            if let newValue = newValue {
                try? keychainClient.set(newValue.value, for: keychainItem)
            } else {
                try? keychainClient.removeItem(keychainItem)
                cookieClient.deleteCookie(named: keychainItem.name)
            }
        }
    }

    private(set) var session: Session? {
        get { localStorage.session }
        set { localStorage.session = newValue }
    }

    private(set) var memberSession: MemberSession? {
        get { localStorage.memberSession }
        set { localStorage.memberSession = newValue }
    }

    @Dependency(\.localStorage) private var localStorage

    @Dependency(\.cookieClient) private var cookieClient

    @Dependency(\.keychainClient) private var keychainClient

    @Dependency(\.sessionsPollingClient) private var sessionsPollingClient

    @Dependency(\.memberSessionsPollingClient) private var memberSessionsPollingClient

    @Dependency(\.date) private var date

    init() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(cookiesDidUpdate(notification:)),
                name: .NSHTTPCookieManagerCookiesChanged,
                object: nil
            )
    }

    func updateSession(_ sessionKind: SessionKind, tokens: [SessionToken], hostUrl: URL?) {
        switch sessionKind {
        case let .member(session):
            memberSession = session
        case let .user(session):
            self.session = session
        }

        tokens.forEach { token in
            updatePersistentStorage(token: token)

            if let cookie = cookieFor(token: token, expiresAt: sessionKind.expiresAt, hostUrl: hostUrl) {
                cookieClient.set(cookie: cookie)
            }
        }
        print("[DEBUG] >>> trigger onAuthChange")
        _onAuthChange.send(())

        switch sessionKind {
        case .member:
            memberSessionsPollingClient.start()
        case .user:
            sessionsPollingClient.start()
        }
    }

    func updatePersistentStorage(token: SessionToken) {
        switch token.kind {
        case .jwt:
            print("[DEBUG] >> Setting jwt to : \(token)")
            sessionJwt = token
        case .opaque:
            sessionToken = token
        }
    }

    func reset() {
        print("[DEBUG] >> resetting session")
        session = nil
        memberSession = nil
        sessionToken = nil
        sessionJwt = nil

        localStorage.user = nil
        localStorage.organization = nil
        localStorage.member = nil

        SessionToken.Kind.allCases
            .map(\.name)
            .forEach(cookieClient.deleteCookie(named:))
        _onAuthChange.send(())
        sessionsPollingClient.stop()
        memberSessionsPollingClient.stop()
    }

    @objc
    func cookiesDidUpdate(notification: Notification) {
        let storage = notification.object as? HTTPCookieStorage ?? .shared

        guard let cookies = storage.cookies else { return }

        cookies
            .filter { SessionToken.Kind.allCases.map(\.name).contains($0.name) }
            .compactMap { cookie in
                // If the cookie is expired, discard the cookie/value
                if let expiresAt = cookie.expiresDate, expiresAt <= date() {
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

        _onAuthChange.send(())
    }

    private func cookieFor(token: SessionToken, expiresAt: Date, hostUrl: URL?) -> HTTPCookie? {
        guard let hostUrl = hostUrl, let urlComponents = URLComponents(url: hostUrl, resolvingAgainstBaseURL: true) else { return nil }

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

extension SessionStorage {
    enum SessionKind {
        case member(MemberSession)
        case user(Session)

        var expiresAt: Date {
            switch self {
            case let .member(session):
                return session.expiresAt
            case let .user(session):
                return session.expiresAt
            }
        }
    }
}
