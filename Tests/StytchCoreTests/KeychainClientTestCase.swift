import XCTest
@testable import StytchCore

final class KeychainClientTestCase: BaseTestCase {
    func testKeychainClient() throws {
        let item: KeychainClient.Item = .init(kind: .token, name: "item")
        let otherItem: KeychainClient.Item = .init(kind: .token, name: "other_item")

        XCTAssertFalse(Current.keychainClient.resultsExistForItem(item))
        XCTAssertFalse(Current.keychainClient.resultsExistForItem(otherItem))

        try Current.keychainClient.set("test test", for: item)

        XCTAssertTrue(Current.keychainClient.resultsExistForItem(item))
        XCTAssertFalse(Current.keychainClient.resultsExistForItem(otherItem))

        XCTAssertEqual(try Current.keychainClient.get(item), "test test")

        try Current.keychainClient.set("test again", for: item)

        XCTAssertEqual(try Current.keychainClient.get(item), "test again")

        try Current.keychainClient.removeItem(item)

        XCTAssertFalse(Current.keychainClient.resultsExistForItem(item))
        XCTAssertFalse(Current.keychainClient.resultsExistForItem(otherItem))
    }

    func testKeychainTokenItem() {
        let item: KeychainClient.Item = .init(kind: .token, name: "item")

        let itemValueForKey: (String) -> KeychainClient.Item.Value = { value in
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
        let item: KeychainClient.Item = .init(kind: .privateKey, name: "item")

        let itemValueForKey: (String) -> KeychainClient.Item.Value = { value in
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
        try Current.keychainClient.set(
            key: data,
            registration: .init(userId: "user_123", userLabel: "user@example.com", registrationId: "registration_123"),
            accessPolicy: .deviceOwnerAuthenticationWithBiometrics
        )
        let results = try Current.keychainClient.get(.privateKeyRegistration)
        XCTAssertNil(results.first?.account)
        XCTAssertEqual(results.first?.label, "user@example.com")
    }

    func testKeychainReset() throws {
        let installIdKey = "stytch_install_id_defaults_key"
        Current.defaults.set(Current.uuid().uuidString, forKey: installIdKey)
        try Current.keychainClient.set("token", for: .sessionToken)
        try Current.keychainClient.set("token_jwt", for: .sessionJwt)
        StytchClient.configure(publicToken: "some public token")
        XCTAssertEqual(try Current.keychainClient.get(.sessionToken), "token")
        XCTAssertEqual(try Current.keychainClient.get(.sessionJwt), "token_jwt")
        Current.defaults.removeObject(forKey: installIdKey)
        StytchClient.configure(publicToken: "another public token")
        XCTAssertNil(try Current.keychainClient.get(.sessionToken))
        XCTAssertNil(try Current.keychainClient.get(.sessionJwt))
    }

    func testKeychainDoesNotResetWhenConfigureIsCalledAgainWithSamePublicToken() throws {
        let installIdKey = "stytch_install_id_defaults_key"
        Current.defaults.set(Current.uuid().uuidString, forKey: installIdKey)
        try Current.keychainClient.set("token", for: .sessionToken)
        try Current.keychainClient.set("token_jwt", for: .sessionJwt)
        StytchClient.configure(publicToken: "some public token")
        XCTAssertEqual(try Current.keychainClient.get(.sessionToken), "token")
        XCTAssertEqual(try Current.keychainClient.get(.sessionJwt), "token_jwt")
        Current.defaults.removeObject(forKey: installIdKey)
        StytchClient.configure(publicToken: "some public token")
        XCTAssertNotNil(try Current.keychainClient.get(.sessionToken))
        XCTAssertNotNil(try Current.keychainClient.get(.sessionJwt))
    }
}
