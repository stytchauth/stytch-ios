import XCTest
@testable import StytchCore

final class KeychainClientTestCase: BaseTestCase {
    func testKeychainClient() throws {
        let item: KeychainItem = .init(kind: .privateKey, name: "item")
        let otherItem: KeychainItem = .init(kind: .encryptionKey, name: "other_item")

        XCTAssertTrue(try Current.keychainClient.getFirstQueryResult(item) == nil)
        XCTAssertTrue(try Current.keychainClient.getFirstQueryResult(otherItem) == nil)

        try Current.keychainClient.setValueForItem(value: .init(data: "test test".data(using: .utf8)!, account: nil, label: nil, generic: nil, accessPolicy: nil), item: item)

        XCTAssertTrue(try Current.keychainClient.getFirstQueryResult(item) != nil)
        XCTAssertTrue(try Current.keychainClient.getFirstQueryResult(otherItem) == nil)

        XCTAssertEqual(try Current.keychainClient.getFirstQueryResult(item)?.stringValue, "test test")

        try Current.keychainClient.setValueForItem(value: .init(data: "test again".data(using: .utf8)!, account: nil, label: nil, generic: nil, accessPolicy: nil), item: item)

        XCTAssertEqual(try Current.keychainClient.getFirstQueryResult(item)?.stringValue, "test again")

        try Current.keychainClient.removeItem(item: item)

        XCTAssertTrue(try Current.keychainClient.getFirstQueryResult(item) == nil)
        XCTAssertTrue(try Current.keychainClient.getFirstQueryResult(otherItem) == nil)
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

    func testKeychainEncryptionKeyItem() {
        let item: KeychainItem = .init(kind: .encryptionKey, name: "encryptionKey")

        // Helper to create a KeychainItem.Value for a given string
        let itemValueForKey: (String) -> KeychainItem.Value = { value in
            .init(
                data: .init(value.utf8),
                account: ENCRYPTEDUSERDEFAULTSKEYNAME,
                label: nil,
                generic: nil,
                accessPolicy: nil
            )
        }

        // Verify the base query used to fetch the encryption key.
        // Expected fields:
        // - service ("svce") set to "encryptionKey"
        // - class ("genp") for generic password
        // - return data and attributes
        // - match limit all
        // - synchronizable any
        // - no authentication UI (skip prompts)
        XCTAssertEqual(
            item.getQuery as CFDictionary,
            [
                "svce": "encryptionKey",
                "class": "genp",
                "m_Limit": "m_LimitAll",
                "r_Data": 1,
                "r_Attributes": 1,
                "nleg": 1,
                "sync": "syna",
                "u_AuthUI": "u_AuthUIS",
            ] as CFDictionary
        )

        // Verify the update segment for an existing encryption key value.
        // Expected fields:
        // - account set to ENCRYPTEDUSERDEFAULTSKEYNAME
        // - value data stored as bytes
        // - pdmn = "ck", meaning kSecAttrAccessibleAfterFirstUnlock
        XCTAssertEqual(
            item.updateQuerySegment(for: itemValueForKey("value")) as CFDictionary,
            [
                "acct": ENCRYPTEDUSERDEFAULTSKEYNAME,
                "v_Data": Data("value".utf8),
                "pdmn": "ck",
            ] as CFDictionary
        )

        // Verify the insert query for a new encryption key value.
        // Expected fields:
        // - account set to ENCRYPTEDUSERDEFAULTSKEYNAME
        // - service set to "encryptionKey"
        // - class = generic password
        // - value data stored as bytes
        // - nleg = 1 (data protection keychain)
        // - pdmn = "ck" (AfterFirstUnlock accessibility)
        XCTAssertEqual(
            item.insertQuery(value: itemValueForKey("new_value")) as CFDictionary,
            [
                "acct": ENCRYPTEDUSERDEFAULTSKEYNAME,
                "svce": "encryptionKey",
                "class": "genp",
                "v_Data": Data("new_value".utf8),
                "nleg": 1,
                "pdmn": "ck", // AfterFirstUnlock
            ] as CFDictionary
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
        try Current.keychainClient.setValueForItem(value: .init(data: "private key".data(using: .utf8)!, account: nil, label: nil, generic: nil, accessPolicy: nil), item: .privateKeyRegistration)
        try Current.keychainClient.setValueForItem(value: .init(data: "encryption key".data(using: .utf8)!, account: nil, label: nil, generic: nil, accessPolicy: nil), item: .encryptionKey)
        StytchClient.configure(configuration: .init(publicToken: "some public token", defaultSessionDuration: 5))
        XCTAssertEqual(try Current.keychainClient.getFirstQueryResult(.privateKeyRegistration)?.stringValue, "private key")
        XCTAssertEqual(try Current.keychainClient.getFirstQueryResult(.encryptionKey)?.stringValue, "encryption key")
        Current.defaults.removeObject(forKey: installIdKey)
        StytchClient.configure(configuration: .init(publicToken: "another public token", defaultSessionDuration: 5))
        XCTAssertNil(try Current.keychainClient.getFirstQueryResult(.privateKeyRegistration))
        XCTAssertNil(try Current.keychainClient.getFirstQueryResult(.encryptionKey))
    }

    func testKeychainDoesNotResetWhenConfigureIsCalledAgainWithSamePublicToken() throws {
        let installIdKey = "stytch_install_id_defaults_key"
        Current.defaults.set(Current.uuid().uuidString, forKey: installIdKey)
        try Current.keychainClient.setValueForItem(value: .init(data: "private key".data(using: .utf8)!, account: nil, label: nil, generic: nil, accessPolicy: nil), item: .privateKeyRegistration)
        try Current.keychainClient.setValueForItem(value: .init(data: "encryption key".data(using: .utf8)!, account: nil, label: nil, generic: nil, accessPolicy: nil), item: .encryptionKey)
        StytchClient.configure(configuration: .init(publicToken: "some public token", defaultSessionDuration: 5))
        XCTAssertEqual(try Current.keychainClient.getFirstQueryResult(.privateKeyRegistration)?.stringValue, "private key")
        XCTAssertEqual(try Current.keychainClient.getFirstQueryResult(.encryptionKey)?.stringValue, "encryption key")
        Current.defaults.removeObject(forKey: installIdKey)
        StytchClient.configure(configuration: .init(publicToken: "some public token", defaultSessionDuration: 5))
        XCTAssertNotNil(try Current.keychainClient.getFirstQueryResult(.privateKeyRegistration))
        XCTAssertNotNil(try Current.keychainClient.getFirstQueryResult(.encryptionKey))
    }
}
