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
    bodyContains: [(key: String, value: JSON)] = [],
    line: UInt = #line,
    file: StaticString = #file
) throws {
    guard let request = request else { return }
    XCTAssertEqual(request.url?.absoluteString, urlString, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.rawValue, file: file, line: line)
    if !bodyContains.isEmpty {
        let bodyJSON = try JSONDecoder().decode(JSON.self, from: XCTUnwrap(request.httpBody))
        bodyContains.forEach { content in
            XCTAssertEqual(bodyJSON[content.key], content.value, file: file, line: line)
        }
    }
}

enum XCTHTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
}
