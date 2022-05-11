import Foundation

struct CookieClient {
    private let setCookie: (HTTPCookie) -> Void
    private let deleteCookieNamed: (String) -> Void

    init(
        setCookie: @escaping (HTTPCookie) -> Void,
        deleteCookieNamed: @escaping (String) -> Void
    ) {
        self.setCookie = setCookie
        self.deleteCookieNamed = deleteCookieNamed
    }

    func set(cookie: HTTPCookie) {
        setCookie(cookie)
    }

    func deleteCookie(named name: String) {
        deleteCookieNamed(name)
    }
}
