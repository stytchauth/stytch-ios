import Foundation

extension Session {
    final class Storage {
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

        var customStorage: CustomStorage?

        init() {
            NotificationCenter.default
                .addObserver(
                    self,
                    selector: #selector(cookiesDidUpdate(notification:)),
                    name: .NSHTTPCookieManagerCookiesChanged,
                    object: nil
                )

            updateLocalStorage(tokens: CookieStorageClient.storedSessionTokens())
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: .NSHTTPCookieManagerCookiesChanged, object: nil)
        }

        func updateSession(_ session: Session, tokens: [Session.Token], hostUrl: URL) {
            updateLocalStorage(tokens: tokens)

            if let customStorage = customStorage {
                customStorage.onUpdateSession(session, tokens, hostUrl)
            } else {
                CookieStorageClient.onUpdateSession(session, tokens: tokens, hostUrl: hostUrl)
            }
        }

        func updateLocalStorage(tokens: [Session.Token]) {
            tokens.forEach { token in
                    switch token.kind {
                    case .jwt:
                        sessionJwt = token
                    case .opaque:
                        sessionToken = token
                    }
                }
        }

        @objc private func cookiesDidUpdate(notification: Notification) {
            updateLocalStorage(
                tokens: CookieStorageClient.storedSessionTokens(storage: notification.object as? HTTPCookieStorage ?? .shared)
            )
        }
    }
}

struct CookieStorageClient {
    static func onUpdateSession(_ session: Session, tokens: [Session.Token], hostUrl: URL) {
        tokens.forEach { token in
            guard let cookie = cookieFor(session: session, token: token, hostUrl: hostUrl) else { return }

            Current.setCookie(cookie)
        }
    }

    static func storedSessionTokens(storage: HTTPCookieStorage = .shared) -> [Session.Token] {
        guard let cookies = storage.cookies else { return [] }

        return cookies
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
    }

    private static func cookieFor(session: Session, token: Session.Token, hostUrl: URL) -> HTTPCookie? {
        guard let urlComponents = URLComponents(url: hostUrl, resolvingAgainstBaseURL: true) else { return nil }

        var properties: [HTTPCookiePropertyKey: Any] = [
            .name: token.name,
            .value: token.value,
            .path: "/",
            .domain: hostUrl.host ?? hostUrl.absoluteString,
            .expires: session.expiresAt
        ]
        if urlComponents.host != "localhost" {
            properties[.secure] = true
        }
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            properties[.sameSitePolicy] = HTTPCookieStringPolicy.sameSiteLax
        }

        return HTTPCookie(properties: properties)
    }
}

extension Session {
    /// Enables the use of your own custom session-token storage mechanism. This can be useful when, for instance,
    /// your app disables the use of HTTP cookies and you need to transmit the tokens to your backend via another mechanism,
    /// e.g. custom headers.
    public struct CustomStorage {
        var onUpdateSession: (Session, [Session.Token], URL) -> Void

        /// Initializes your CustomStorage instance.
        /// - Parameter onUpdateSession: Should be used to listen for updates to the Session and corresponding tokens from the
        /// StytchClient to allow you to store the tokens as needed.
        public init(onUpdateSession: @escaping (Session, [Session.Token], URL) -> Void) {
            self.onUpdateSession = onUpdateSession
        }

        /// To be called when you receive updated session tokens from your backend, as well as after app startup
        /// to ensure the StytchClient's local storage is up to date.
        /// - Parameter tokens: The updated token values.
        public func onUpdate(tokens: [Session.Token]) {
            Current.sessionStorage.updateLocalStorage(tokens: tokens)
        }
    }
}
