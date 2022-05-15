import XCTest
@testable import StytchCore

final class CookieClientTestCase: BaseTestCase {
    func testCookieClient() throws {
        XCTAssertTrue(cookies.isEmpty)

        Current.cookieClient.set(
            cookie: try XCTUnwrap(HTTPCookie(properties: [.name: "cookie", .value: "test", .domain: "domain.com", .path: "/"]))
        )

        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(try XCTUnwrap(cookies.last).name, "cookie")

        Current.cookieClient.deleteCookie(named: "other_name")

        XCTAssertFalse(cookies.isEmpty)

        Current.cookieClient.set(
            cookie: try XCTUnwrap(HTTPCookie(properties: [.name: "other_name", .value: "test", .domain: "domain.com", .path: "/"]))
        )

        XCTAssertEqual(cookies.count, 2)

        Current.cookieClient.deleteCookie(named: "cookie")

        XCTAssertEqual(cookies.count, 1)

        XCTAssertEqual(try XCTUnwrap(cookies.last).name, "other_name")

        Current.cookieClient.deleteCookie(named: "other_name")

        XCTAssertTrue(cookies.isEmpty)
    }
}
