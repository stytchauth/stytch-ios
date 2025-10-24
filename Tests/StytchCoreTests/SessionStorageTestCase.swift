import Foundation
import XCTest
@testable import StytchCore

final class SessionStorageTestCase: BaseTestCase {
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        userDefaultsLastModifiedOffset = 0
    }

    func testIntermediateSessionTokenExpiresAfter11Minutes() {
        let istItem: EncryptedUserDefaultsItem = .intermediateSessionToken

        // clear the IST
        try? Current.userDefaultsClient.removeItem(item: istItem)

        // set the date created offset to 11 minutes so that the IST will be expired and return nil
        userDefaultsLastModifiedOffset = 11

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
        userDefaultsLastModifiedOffset = 5

        // call updateSession with only the IST which will assign it to the keychain item for the IST
        Current.sessionManager.updateSession(intermediateSessionToken: "1234567890")

        // the IST should not be nil since its only been more than 5 minutes
        XCTAssertNotNil(Current.sessionManager.intermediateSessionToken)
    }
}
