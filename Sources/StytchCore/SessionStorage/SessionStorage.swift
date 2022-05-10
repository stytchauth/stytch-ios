import Foundation

public extension Session {
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

        private(set) var session: Session? {
            get { _session.value }
            set {
//                guard newValue != _session.value else { return }
                _session.value = newValue
            }
        }

        private var _session: Atomic<Session?> = .init(value: nil)

        var strategy: Strategy = .cookies {
            didSet { update(storageStrategy: strategy) }
        }

        init() {
            update(storageStrategy: strategy)
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: .NSHTTPCookieManagerCookiesChanged, object: nil)
        }

        func updateSession(_ session: Session, tokens: [Session.Token], hostUrl: URL) {
            updateLocalStorage(tokens: tokens)

            switch strategy {
            case .cookies:
                CookieStorageClient.onUpdateSession(tokens: tokens, expiresAt: session.expiresAt, hostUrl: hostUrl)
            case .keychain:
                break
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
                switch strategy {
                case .cookies:
                    break
                case .keychain:
                    KeychainStorageClient.onUpdate(tokens: tokens)
                }
            }
        }

        private func update(storageStrategy: Strategy) {
            switch storageStrategy {
            case .cookies:
                NotificationCenter.default
                    .addObserver(
                        self,
                        selector: #selector(cookiesDidUpdate(notification:)),
                        name: .NSHTTPCookieManagerCookiesChanged,
                        object: nil
                    )
                updateLocalStorage(tokens: CookieStorageClient.storedSessionTokens())
            case .keychain:
                NotificationCenter.default.removeObserver(self, name: .NSHTTPCookieManagerCookiesChanged, object: nil)
                updateLocalStorage(tokens: KeychainStorageClient.storedSessionTokens())
            }
        }

        @objc private func cookiesDidUpdate(notification: Notification) {
            updateLocalStorage(
                tokens: CookieStorageClient.storedSessionTokens(
                    storage: notification.object as? HTTPCookieStorage ?? .shared
                )
            )
        }
    }
}
