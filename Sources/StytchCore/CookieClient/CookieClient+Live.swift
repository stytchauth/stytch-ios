import Foundation

extension CookieClient {
    // swiftlint:disable:next trailing_closure
    static let live: Self = .init(
        setCookie: HTTPCookieStorage.shared.setCookie(_:),
        deleteCookieNamed: { name in
            HTTPCookieStorage.shared.cookies?
                .filter { $0.name == name }
                .forEach(HTTPCookieStorage.shared.deleteCookie(_:))
        }
    )
}
