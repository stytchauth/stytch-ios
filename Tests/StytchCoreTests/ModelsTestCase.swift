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
}
