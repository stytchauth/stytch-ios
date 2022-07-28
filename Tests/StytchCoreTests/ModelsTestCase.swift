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

    func testLossyArray() throws {
        struct Test: Decodable {
            let stringDigit: String
        }
        let decoder = JSONDecoder()
        do {
            let json = "[{\"stringDigit\":\"one\"},{\"stringDigit\":2},{\"stringDigit\":\"three\"}]"
            let testArray = try decoder.decode(LossyArray<Test>.self, from: Data(json.utf8))
            XCTAssertEqual(testArray.wrappedValue.count, 2)
            XCTAssertEqual(testArray.wrappedValue[0].stringDigit, "one")
            XCTAssertEqual(testArray.wrappedValue[1].stringDigit, "three")
        }
        do {
            let json = "[{\"stringDigit\":\"one\"},{\"stringDigit\":\"two\"},{\"stringDigit\":\"three\"}]"
            let testArray = try decoder.decode(LossyArray<Test>.self, from: Data(json.utf8))
            XCTAssertEqual(testArray.wrappedValue.count, 3)
            XCTAssertEqual(testArray.wrappedValue[0].stringDigit, "one")
            XCTAssertEqual(testArray.wrappedValue[1].stringDigit, "two")
            XCTAssertEqual(testArray.wrappedValue[2].stringDigit, "three")
        }
    }
}
