import XCTest
@testable import StytchCore

final class KeychainClientTestCase: BaseTestCase {
    func testKeychainClient() throws {
        let item: KeychainItem = .init(kind: .token, name: "item")
        let otherItem: KeychainItem = .init(kind: .token, name: "other_item")

        XCTAssertFalse(Current.keychainClient.resultsExistForItem(item))
        XCTAssertFalse(Current.keychainClient.resultsExistForItem(otherItem))

        try Current.keychainClient.setStringValue("test test", for: item)

        XCTAssertTrue(Current.keychainClient.resultsExistForItem(item))
        XCTAssertFalse(Current.keychainClient.resultsExistForItem(otherItem))

        XCTAssertEqual(try Current.keychainClient.getStringValue(item), "test test")

        try Current.keychainClient.setStringValue("test again", for: item)

        XCTAssertEqual(try Current.keychainClient.getStringValue(item), "test again")

        try Current.keychainClient.removeItem(item: item)

        XCTAssertFalse(Current.keychainClient.resultsExistForItem(item))
        XCTAssertFalse(Current.keychainClient.resultsExistForItem(otherItem))
    }

    func testKeychainTokenItem() {
        let item: KeychainItem = .init(kind: .token, name: "item")

        let itemValueForKey: (String) -> KeychainItem.Value = { value in
            .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessPolicy: nil)
        }

        XCTAssertEqual(
            item.getQuery as CFDictionary,
            ["svce": "item", "class": "genp", "m_Limit": "m_LimitAll", "r_Data": 1, "r_Attributes": 1, "nleg": 1, "sync": "syna"] as CFDictionary
        )
        XCTAssertEqual(
            item.updateQuerySegment(for: itemValueForKey("value")) as CFDictionary,
            ["v_Data": Data("value".utf8), "pdmn": "ck"] as CFDictionary
        )
        XCTAssertEqual(
            item.insertQuery(value: itemValueForKey("new_value")) as CFDictionary,
            ["svce": "item", "class": "genp", "v_Data": Data("new_value".utf8), "nleg": 1, "pdmn": "ck"] as CFDictionary
        )
    }

    func testKeychainPrivateKeyItem() {
        let item: KeychainItem = .init(kind: .privateKey, name: "item")

        let itemValueForKey: (String) -> KeychainItem.Value = { value in
            .init(data: .init(value.utf8), account: nil, label: nil, generic: nil, accessPolicy: .deviceOwnerAuthenticationWithBiometrics)
        }
        let expectedAccessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            [.biometryCurrentSet],
            nil
        )

        XCTAssertEqual(
            item.getQuery as CFDictionary,
            ["svce": "item", "class": "genp", "m_Limit": "m_LimitAll", "r_Data": 1, "r_Attributes": 1, "nleg": 1, "sync": "syna"] as CFDictionary
        )
        XCTAssertEqual(
            item.updateQuerySegment(for: itemValueForKey("value")) as CFDictionary,
            ["v_Data": Data("value".utf8), "accc": expectedAccessControl as Any] as CFDictionary
        )
        XCTAssertEqual(
            item.insertQuery(value: itemValueForKey("new_value")) as CFDictionary,
            ["svce": "item", "class": "genp", "v_Data": Data("new_value".utf8), "nleg": 1, "accc": expectedAccessControl as Any] as CFDictionary
        )
    }

    func testQueryResults() throws {
        let data = try Current.cryptoClient.dataWithRandomBytesOfCount(32)
        try Current.keychainClient.setPrivateKeyRegistration(
            key: data,
            registration: .init(userId: "user_123", userLabel: "user@example.com", registrationId: "registration_123"),
            accessPolicy: .deviceOwnerAuthenticationWithBiometrics
        )
        let results = try Current.keychainClient.getQueryResults(item: .privateKeyRegistration)
        XCTAssertNil(results.first?.account)
        XCTAssertEqual(results.first?.label, "user@example.com")
    }

    func testKeychainReset() throws {
        let installIdKey = "stytch_install_id_defaults_key"
        Current.defaults.set(Current.uuid().uuidString, forKey: installIdKey)
        try Current.keychainClient.setStringValue("token", for: .sessionToken)
        try Current.keychainClient.setStringValue("token_jwt", for: .sessionJwt)
        StytchClient.configure(configuration: .init(publicToken: "some public token"))
        XCTAssertEqual(try Current.keychainClient.getStringValue(.sessionToken), "token")
        XCTAssertEqual(try Current.keychainClient.getStringValue(.sessionJwt), "token_jwt")
        Current.defaults.removeObject(forKey: installIdKey)
        StytchClient.configure(configuration: .init(publicToken: "another public token"))
        XCTAssertNil(try Current.keychainClient.getStringValue(.sessionToken))
        XCTAssertNil(try Current.keychainClient.getStringValue(.sessionJwt))
    }

    func testKeychainDoesNotResetWhenConfigureIsCalledAgainWithSamePublicToken() throws {
        let installIdKey = "stytch_install_id_defaults_key"
        Current.defaults.set(Current.uuid().uuidString, forKey: installIdKey)
        try Current.keychainClient.setStringValue("token", for: .sessionToken)
        try Current.keychainClient.setStringValue("token_jwt", for: .sessionJwt)
        StytchClient.configure(configuration: .init(publicToken: "some public token"))
        XCTAssertEqual(try Current.keychainClient.getStringValue(.sessionToken), "token")
        XCTAssertEqual(try Current.keychainClient.getStringValue(.sessionJwt), "token_jwt")
        Current.defaults.removeObject(forKey: installIdKey)
        StytchClient.configure(configuration: .init(publicToken: "some public token"))
        XCTAssertNotNil(try Current.keychainClient.getStringValue(.sessionToken))
        XCTAssertNotNil(try Current.keychainClient.getStringValue(.sessionJwt))
    }
}
