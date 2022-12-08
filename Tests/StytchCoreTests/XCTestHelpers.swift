import XCTest

func XCTAssertRequest(
    _ request: URLRequest?,
    urlString: String,
    method: XCTHTTPMethod = .get,
    @XCTHTTPBodyContainsBuilder bodyContains: () -> [String] = { [] },
    line: UInt = #line,
    file: StaticString = #file
) throws {
    guard let request = request else { return }
    XCTAssertEqual(request.url?.absoluteString, urlString, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.rawValue, file: file, line: line)
    if case let bodyContents = bodyContains(), !bodyContents.isEmpty {
        let bodyString = try XCTUnwrap(String(data: XCTUnwrap(request.httpBody), encoding: .utf8))
        bodyContents.forEach { content in
            XCTAssertTrue(bodyString.contains(content), "Content missing from body: \(content)\nBody: \(bodyString)", file: file, line: line)
        }
    }
}

enum XCTHTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
}

@resultBuilder
enum XCTHTTPBodyContainsBuilder {
    static func buildBlock(_ components: String...) -> [String] {
        components
    }

    static func buildExpression(_ expression: (String, String)) -> String {
        "\"\(expression.0)\":\"\(expression.1)\""
    }

    static func buildExpression(_ expression: (String, Int)) -> String {
        "\"\(expression.0)\":\(expression.1)"
    }

    static func buildExpression(_ expression: (String, String)) -> [String] {
        [Self.buildExpression(expression)]
    }
}
