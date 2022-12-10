import StytchCore
import XCTest

func XCTAssertThrowsErrorAsync<T: Sendable>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {
        errorHandler(error)
    }
}

func XCTAssertRequest(
    _ request: URLRequest?,
    urlString: String,
    method: XCTHTTPMethod,
    bodyContains: [(key: String, value: JSON)]? = nil,
    headersEqual expectedHeaders: [String: String]? = nil,
    line: UInt = #line,
    file: StaticString = #file
) throws {
    let request = try XCTUnwrap(request)
    XCTAssertEqual(request.url?.absoluteString, urlString, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.rawValue, file: file, line: line)
    if let bodyContains = bodyContains {
        let bodyJSON = try JSONDecoder().decode(JSON.self, from: XCTUnwrap(request.httpBody))
        if bodyContains.isEmpty {
            XCTAssertEqual(bodyJSON, [])
        } else {
            bodyContains.forEach { content in
                XCTAssertEqual(
                    content.key.components(separatedBy: ".").reduce(bodyJSON) { $0?[$1] },
                    content.value,
                    file: file,
                    line: line
                )
            }
        }
    }
    if let expectedHeaders = expectedHeaders {
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
    }
}

enum XCTHTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
}
