import Foundation
import XCTest
@testable import StytchCore

final class SessionStorageTestCase: BaseTestCase {
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        keychainDateCreatedOffsetInMinutes = 0
    }

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

    func testIntermediateSessionTokenExpiresAfter11Minutes() {
        let keychainItem: KeychainItem = .intermediateSessionToken

        // clear the IST
        try? Current.keychainClient.removeItem(item: keychainItem)

        // set the date created offset to 11 minutes so that the IST will be expired and return nil
        keychainDateCreatedOffsetInMinutes = 11

        // call updateSession with only the IST which will assign it to the keychain item for the IST
        Current.sessionManager.updateSession(intermediateSessionToken: "1234567890")

        // the IST should be nil since its been more than 10 minutes
        XCTAssertNil(Current.sessionManager.intermediateSessionToken)
    }

    func testIntermediateSessionTokenIsStillValidAfter5Minutes() {
        let keychainItem: KeychainItem = .intermediateSessionToken

        // clear the IST
        try? Current.keychainClient.removeItem(item: keychainItem)

        // set the date created offset to only 5 minutes so that the IST is still valid
        keychainDateCreatedOffsetInMinutes = 5

        // call updateSession with only the IST which will assign it to the keychain item for the IST
        Current.sessionManager.updateSession(intermediateSessionToken: "1234567890")

        // the IST should not be nil since its only been more than 5 minutes
        XCTAssertNotNil(Current.sessionManager.intermediateSessionToken)
    }
}
