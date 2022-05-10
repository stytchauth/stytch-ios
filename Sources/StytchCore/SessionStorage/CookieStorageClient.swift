import Foundation

extension Session.Storage {
    enum CookieStorageClient {
        static func onUpdateSession(tokens: [Session.Token], expiresAt: Date, hostUrl: URL) {
            tokens.forEach { token in
                guard let cookie = cookieFor(token: token, expiresAt: expiresAt, hostUrl: hostUrl) else { return }

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

        private static func cookieFor(token: Session.Token, expiresAt: Date, hostUrl: URL) -> HTTPCookie? {
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
