import XCTest
@testable import StytchCore

final class KeychainClientTestCase: BaseTestCase {
    func testKeychainClient() throws {
        let item: KeychainClient.Item = .init(kind: .token, name: "item")
        let otherItem: KeychainClient.Item = .init(kind: .token, name: "other_item")

        XCTAssertNil(try Current.keychainClient.get(item))
        XCTAssertNil(try Current.keychainClient.get(otherItem))

        try Current.keychainClient.set("test test", for: item)

        XCTAssertTrue(Current.keychainClient.resultExists(for: item))
        XCTAssertFalse(Current.keychainClient.resultExists(for: otherItem))

        XCTAssertEqual(try Current.keychainClient.get(item), "test test")

        try Current.keychainClient.set("test again", for: item)

        XCTAssertEqual(try Current.keychainClient.get(item), "test again")

        try Current.keychainClient.remove(item)

        XCTAssertFalse(Current.keychainClient.resultExists(for: item))
        XCTAssertFalse(Current.keychainClient.resultExists(for: otherItem))
    }

    func testKeychainItem() {
        let item: KeychainClient.Item = .init(kind: .token, name: "item")

        XCTAssertEqual(
            item.getQuery,
            ["svce": "item", "class": "genp", "m_Limit": "m_LimitOne", "r_Data": 1, "nleg": 1] as CFDictionary
        )
        XCTAssertEqual(
            item.querySegmentForUpdate(for: "value") as CFDictionary,
            ["v_Data": Data("value".utf8)] as CFDictionary
        )
        XCTAssertEqual(
            item.insertQuery(value: "new_value") as CFDictionary,
            ["svce": "item", "class": "genp", "v_Data": Data("new_value".utf8), "nleg": 1] as CFDictionary
        )
    }
}
