import XCTest
@testable import StytchCore

final class ModelsTestCase: BaseTestCase {
    func testPath() {
        let path = Path(rawValue: "path")
        XCTAssertEqual(path.rawValue, "path")
        XCTAssertEqual(path.appendingPath("").rawValue, "path")
        XCTAssertEqual(path.appendingPath("new_path").rawValue, "path/new_path")
        XCTAssertEqual(
            path.appendingPath("new_path").appendingPath("other_path").rawValue,
            "path/new_path/other_path"
        )
    }

    func testUnion() {
        struct FirstType {
            let blah: String
        }
        struct SecondType {
            let bloop: String
        }
        let union = Union(lhs: FirstType(blah: "blah"), rhs: SecondType(bloop: "bloop"))
        XCTAssertEqual(union.blah, "blah")
        XCTAssertEqual(union.bloop, "bloop")
    }

    func testUnionCodable() throws {
        struct FirstType: Codable {
            let blah: String
        }
        struct SecondType: Codable {
            let bloop: String
        }

        let json: JSON = ["blah": "blah", "bloop": "bloop"]
        let data = try JSONEncoder().encode(json)
        let union = try JSONDecoder().decode(Union<FirstType, SecondType>.self, from: data)
        XCTAssertEqual(union.blah, "blah")
        XCTAssertEqual(union.bloop, "bloop")
        let newData = try JSONEncoder().encode(union)
        let decodedJson = try JSONDecoder().decode(JSON.self, from: newData)
        XCTAssertEqual(decodedJson, json)
    }
}
