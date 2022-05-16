import Foundation
import XCTest
@testable import StytchCore

final class SessionStorageTestCase: BaseTestCase {
    func testNotification() throws {
        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
        try HTTPCookieStorage.shared.setCookie(
            XCTUnwrap(.init(
                properties: [.name: "stytch_session_jwt", .value: "new_value", .domain: "my-domain.com", .path: "/"]
            ))
        )
        try HTTPCookieStorage.shared.setCookie(
            XCTUnwrap(.init(
                properties: [.name: "stytch_session", .value: "opaque", .domain: "my-domain.com", .path: "/"]
            ))
        )
        NotificationCenter.default.post(name: .NSHTTPCookieManagerCookiesChanged, object: HTTPCookieStorage.shared)
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("new_value"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("opaque"))
    }
}
