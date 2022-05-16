import XCTest
@testable import StytchCore

final class ExtensionsTestCase: BaseTestCase {
    func testStringExtensions() {
        XCTAssertEqual("blah-blah-bloop".base64Encoded, "YmxhaC1ibGFoLWJsb29w")
        XCTAssertEqual("blah-blah-bloop".dropLast { $0 != "-" }, "blah-blah-")
    }

    func testURLComponentsExtensions() throws {
        func testIsLocalHost(urlString: String, expectation: Bool, line: UInt = #line) throws {
            let urlComponents = try XCTUnwrap(URLComponents(string: urlString))
            XCTAssertEqual(urlComponents.isLocalHost, expectation, line: line)
        }

        try [
            ("http://127.0.0.1/my-path", true),
            ("http://localhost:8080/my-path", true),
            ("http://[::1]/my-path", true),
            ("https://my-domain.com/my-path", false),
        ].forEach { urlString, expectation in
            try testIsLocalHost(urlString: urlString, expectation: expectation)
        }
    }
}
