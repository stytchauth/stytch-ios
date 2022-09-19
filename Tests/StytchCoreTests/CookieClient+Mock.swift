import Foundation
@testable import StytchCore

extension CookieClient {
    static var testCookies: [HTTPCookie] = []

    static func mock() -> Self {
        testCookies = []
        return .init { cookie in
            testCookies.append(cookie)
        } deleteCookieNamed: { name in
            testCookies.removeAll { $0.name == name }
        }
    }
}
