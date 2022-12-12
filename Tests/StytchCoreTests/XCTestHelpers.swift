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
    headers expectedHeaders: [String: String]? = nil,
    line: UInt = #line,
    file: StaticString = #file
) throws {
    let request = try XCTUnwrap(request)
    XCTAssertEqual(request.url?.absoluteString, urlString, file: file, line: line)
    XCTAssertEqual(request.httpMethod, method.stringValue, file: file, line: line)
    if let expectedBody = method.body {
        let bodyJSON = try JSONDecoder().decode(JSON.self, from: XCTUnwrap(request.httpBody))
        XCTAssertEqual(bodyJSON, expectedBody)
    }
    if let expectedHeaders = expectedHeaders {
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
    }
}

enum XCTHTTPMethod {
    case get
    case delete
    case post(JSON)
    case put(JSON)

    var stringValue: String {
        switch self {
        case .get:
            return "GET"
        case .delete:
            return "DELETE"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        }
    }

    var body: JSON? {
        switch self {
        case let .post(body), let .put(body):
            return body
        case .get, .delete:
            return nil
        }
    }
}
