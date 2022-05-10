import Foundation

public extension Session {
    final class Storage {
        private(set) var sessionToken: Session.Token? {
            get { try? Current.keychainGet(.init(kind: .token, name: Session.Token.Kind.opaque.name)).map(Session.Token.opaque) }
            set {
                let keychainItem: KeychainClient.Item = .init(kind: .token, name: Session.Token.Kind.opaque.name)
                if let newValue = newValue {
                    try? Current.keychainSet(newValue.value, keychainItem)
                } else {
                    try? Current.keychainRemove(keychainItem)
                    // TODO: - need to also clear the cookie
                }
            }
        }

        private(set) var sessionJwt: Session.Token? {
            get { try? Current.keychainGet(.init(kind: .token, name: Session.Token.Kind.jwt.name)).map(Session.Token.opaque) }
            set {
                let keychainItem: KeychainClient.Item = .init(kind: .token, name: Session.Token.Kind.jwt.name)
                if let newValue = newValue {
                    try? Current.keychainSet(newValue.value, keychainItem)
                } else {
                    try? Current.keychainRemove(keychainItem)
                    // TODO: - need to also clear the cookie
                }
            }
        }

        // TODO: - does this need to be persisted
        private(set) var session: Session? {
            get {
                do {
                    guard let json = try Current.keychainGet(.init(kind: .token, name: "stytch_session")) else { return nil }
                    return try Current.jsonDecoder.decode(Session.self, from: Data(json.utf8))
                } catch {
                    return nil
                }
            }
            set {
                do {
                    let keychainItem: KeychainClient.Item = .init(kind: .token, name: "stytch_session")
                    if let newValue = newValue {
                        let data = try Current.jsonEncoder.encode(newValue)
                        if let jsonString = String(data: data, encoding: .utf8) {
                            try Current.keychainSet(jsonString, keychainItem)
                        }
                    } else {
                        try Current.keychainRemove(keychainItem)
                    }
                } catch {}
            }
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

        deinit {
            NotificationCenter.default.removeObserver(self, name: .NSHTTPCookieManagerCookiesChanged, object: nil)
        }

        func updateSession(_ session: Session, tokens: [Session.Token], hostUrl: URL) {
            tokens.forEach { token in
                updatePersistentStorage(token: token)

                if let cookie = cookieFor(token: token, expiresAt: session.expiresAt, hostUrl: hostUrl) {
                    Current.setCookie(cookie)
                }
            }
        }

        func updatePersistentStorage(token: Session.Token) {
            do {
                try Current.keychainSet(token.value, .init(kind: .token, name: token.name))
            } catch {}
        }

        @objc private func cookiesDidUpdate(notification: Notification) {
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
}
