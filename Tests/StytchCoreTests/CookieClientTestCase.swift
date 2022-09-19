import XCTest
@testable import StytchCore

final class CookieClientTestCase: BaseTestCase {
    func testCookieClient() throws {
        XCTAssertTrue(CookieClient.testCookies.isEmpty)

        Current.cookieClient.set(
            cookie: try XCTUnwrap(HTTPCookie(properties: [.name: "cookie", .value: "test", .domain: "domain.com", .path: "/"]))
        )

        XCTAssertEqual(CookieClient.testCookies.count, 1)
        XCTAssertEqual(try XCTUnwrap(CookieClient.testCookies.last).name, "cookie")

        Current.cookieClient.deleteCookie(named: "other_name")

        XCTAssertFalse(CookieClient.testCookies.isEmpty)

        Current.cookieClient.set(
            cookie: try XCTUnwrap(HTTPCookie(properties: [.name: "other_name", .value: "test", .domain: "domain.com", .path: "/"]))
        )

        XCTAssertEqual(CookieClient.testCookies.count, 2)

        Current.cookieClient.deleteCookie(named: "cookie")

        XCTAssertEqual(CookieClient.testCookies.count, 1)

        XCTAssertEqual(try XCTUnwrap(CookieClient.testCookies.last).name, "other_name")

        Current.cookieClient.deleteCookie(named: "other_name")

        XCTAssertTrue(CookieClient.testCookies.isEmpty)
    }
}
