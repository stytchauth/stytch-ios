import StytchCore
import XCTest

func XCTAssertThrowsErrorAsync<T, R: Error>(
    _ expression: @autoclosure () async throws -> T,
    _ errorThrown: @autoclosure () -> R,
    _ message: @autoclosure () -> String = "This method should fail",
    file: StaticString = #filePath,
    line: UInt = #line
) async where T: Sendable, R: Equatable, R: StytchError {
    do {
        _ = try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {
        XCTAssertEqual(error as? R, errorThrown())
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
        XCTAssertEqualJSON(bodyJSON, expectedBody, file: file, line: line)
    }
    if let expectedHeaders = expectedHeaders {
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders, file: file, line: line)
    }
}

enum XCTHTTPMethod {
    case get
    case delete
    case post(JSON?)
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
        case let .put(body):
            return body
        case let .post(body):
            return body
        case .get, .delete:
            return nil
        }
    }
}

private func XCTAssertEqualJSON(_ value1: JSON, _ value2: JSON, file: StaticString = #file, line: UInt = #line) {
    guard let message = value2.difference(from: value1) else { return }
    XCTFail("JSON differed:\n" + message, file: file, line: line)
}

private extension JSON {
    func difference(from other: JSON?) -> String? {
        switch (self, other) {
        case let (.object(lhs), .object(rhs)):
            let lhsKeys = lhs.keys.sorted()
            if let description = lhsKeys.difference(from: rhs.keys.sorted()).testDescription(descriptor: "key") {
                return description
            } else {
                for key in lhsKeys {
                    if let lhsValue = lhs[key], let rhsValue = rhs[key] {
                        if let description = lhsValue?.difference(from: rhsValue) {
                            return description
                        }
                    }
                }
            }
            return nil
        case let (.array(lhs), .array(rhs)):
            return lhs.difference(from: rhs).testDescription(descriptor: "value")
        case let (.number(lhs), .number(rhs)):
            return lhs != rhs ? "\(lhs) != \(rhs)" : nil
        case let (.boolean(lhs), .boolean(rhs)):
            return lhs != rhs ? "\(lhs) != \(rhs)" : nil
        case let (.string(lhs), .string(rhs)):
            return lhs.difference(from: rhs).testDescription(descriptor: "character").map { "\(lhs) != \(rhs)\n" + $0 }
        default:
            return "\(self) != \(other ?? "nil")"
        }
    }
}

private extension CollectionDifference {
    func testDescription(descriptor: String) -> String? {
        guard case let descriptions = compactMap({ $0.testDescription(descriptor: descriptor) }), !descriptions.isEmpty else { return nil }

        return "- " + descriptions.joined(separator: "\n- ")
    }
}

private extension CollectionDifference.Change {
    func testDescription(descriptor: String) -> String? {
        switch self {
        case let .insert(index, element, association):
            if let oldIndex = association {
                return "Element moved from index \(oldIndex) to \(index): \(element)"
            } else {
                return "Expected \(descriptor) missing: \(element)"
            }
        case let .remove(_, element, association):
            guard association == nil else {
                return nil
            }

            return "Unexpected \(descriptor) present: \(element)"
        }
    }
}
