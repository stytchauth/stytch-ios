import Foundation

extension CookieClient {
    static let live: Self = .init(
        setCookie: HTTPCookieStorage.shared.setCookie(_:),
        deleteCookieNamed: { name in
            HTTPCookieStorage.shared.cookies?
                .filter { $0.name == name }
                .forEach(HTTPCookieStorage.shared.deleteCookie(_:))
        }
    )
}
