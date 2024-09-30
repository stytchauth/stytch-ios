import XCTest
@testable import StytchCore

// swiftlint:disable type_contents_order

final class JSONTestCase: BaseTestCase {
    func testNilValueInJSONDictionary() {
        let jsonString =
            """
            {
                "custom_claims": {
                    "https://example.co/jwt/claims": {
                        "can_assume_user": null,
                        "roles": [
                            "admin"
                        ]
                    }
                }
            }
            """

        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }

        if let object = try? Current.jsonDecoder.decode(ObjectToDecode.self, from: data) {
            print(object.customClaims)
        } else {
            XCTFail("Failed To Parse JSON")
        }
    }

    struct ObjectToDecode: Codable {
        let customClaims: JSON
    }
}
