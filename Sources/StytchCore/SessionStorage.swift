import Foundation

// TODO: - Should this be a session subscription layer? Which just has hooks when new tokens are received. Would allow the customer to own the storage of the tokens (keychain, for instance, vs cookies)
// Perhaps I can also provide a hook to allow URLRequest modification (probably not just allow access to current token
public protocol SessionStorageType {
    var sessionToken: String? { get }
    var sessionJwt: String? { get }
}

final class SessionStorage {
    private(set) var sessionToken: Session.Token? {
        get { _sessionToken.value }
        set {
            guard newValue != _sessionToken.value else { return }
            _sessionToken.value = newValue
        }
    }

    private var _sessionToken: Atomic<Session.Token?> = .init(value: nil)

    private(set) var sessionJwt: Session.Token? {
        get { _sessionJwt.value }
        set {
            guard newValue != _sessionJwt.value else { return }
            _sessionJwt.value = newValue
        }
    }

    private var _sessionJwt: Atomic<Session.Token?> = .init(value: nil)

    private let setCookie: (HTTPCookie) -> Void

    init(
        setCookie: @escaping (HTTPCookie) -> Void = HTTPCookieStorage.shared.setCookie(_:)
    ) {
        self.setCookie = setCookie

        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(cookiesDidUpdate(notification:)),
                name: .NSHTTPCookieManagerCookiesChanged,
                object: nil
            )
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSHTTPCookieManagerCookiesChanged, object: nil)
    }

    func updateSession(tokens: [Session.Token], domain: String) {
        tokens.forEach { token in
            switch token.kind {
            case .jwt:
                sessionJwt = token
            case .opaque:
                sessionToken = token
            }

            guard let cookie = cookieFor(token: token, domain: domain) else { return }

            setCookie(cookie)
        }
    }

    private func cookieFor(token: Session.Token, domain: String) -> HTTPCookie? {
        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: token.name,
            .value: token.value,
            .path: "/",
            .domain: domain,
            .expires: token.expiresAt,
            .secure: true
        ]
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            properties[.sameSitePolicy] = HTTPCookieStringPolicy.sameSiteLax
        }
        return HTTPCookie(properties: properties)
    }

    @objc private func cookiesDidUpdate(notification: Notification) {
        let cookieStorage = notification.object as? HTTPCookieStorage ?? HTTPCookieStorage.shared

        cookieStorage.cookies?
            .filter { Session.Token.Kind.allCases.map(\.name).contains($0.name) }
            .forEach { cookie in
                // TODO: confirm we want the cookie expiration to align with the session expiration, and that we want to use distantFuture as a fallback
                guard case let expiresAt = cookie.expiresDate ?? Date.distantFuture, expiresAt <= Date() else {
                    return
                }

                switch cookie.name {
                case Session.Token.Kind.jwt.name:
                    sessionJwt = .init(kind: .jwt, value: cookie.value, expiresAt: expiresAt)
                case Session.Token.Kind.opaque.name:
                    sessionToken = .init(kind: .opaque, value: cookie.value, expiresAt: expiresAt)
                default:
                    break
                }
            }
    }
}

struct Atomic<T> {
    private let lock: NSLock = .init()

    var value: T {
        get { withLock { _value } }
        set { withLock { _value = newValue } }
    }

    private var _value: T

    init(value: T) {
        self._value = value
    }

    private func withLock<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }
}
