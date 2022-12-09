import Foundation
@testable import StytchCore

extension CookieClient {
    static var testCookies: [HTTPCookie] = []

    static func mock() -> Self {
        testCookies = []
        let lock: NSLock = .init()
        return .init { cookie in
            lock.withLock {
                testCookies.append(cookie)
            }
        } deleteCookieNamed: { name in
            lock.withLock {
                testCookies.removeAll { $0.name == name }
            }
        }
    }
}
