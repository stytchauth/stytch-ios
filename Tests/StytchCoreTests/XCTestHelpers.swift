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
    body expectedBody: JSON? = nil,
    headers expectedHeaders: [String: String]? = nil,
    line: UInt = #line,
    file: StaticString = #file
) throws {
    let request = try XCTUnwrap(request)
    XCTAssertEqual(request.url?.absoluteString, urlString, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.rawValue, file: file, line: line)
    if let expectedBody = expectedBody {
        let bodyJSON = try JSONDecoder().decode(JSON.self, from: XCTUnwrap(request.httpBody))
        XCTAssertEqual(bodyJSON, expectedBody)
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
