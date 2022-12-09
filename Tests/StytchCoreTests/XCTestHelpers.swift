import XCTest

extension XCTest {
    func XCTAssertThrowsError<T: Sendable>(
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
}

enum XCTHTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
}

@resultBuilder
enum XCTHTTPBodyContainsBuilder {
    static func buildPartialBlock<T: LosslessStringConvertible>(first: (String, T)) -> [String] {
        ["\"\(first.0)\":\(jsonValue(first.1))"]
    }

    static func buildPartialBlock<T: LosslessStringConvertible>(accumulated: [String], next: (String, T)) -> [String] {
        accumulated + buildPartialBlock(first: next)
    }

    private static func jsonValue<T: LosslessStringConvertible>(_ value: T) -> String {
        switch value {
        case is any Numeric:
            return "\(value)"
        default:
            return "\"\(value)\""
        }
    }
}
