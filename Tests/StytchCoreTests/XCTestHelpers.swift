import StytchCore
@preconcurrency import SwiftyJSON
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
        // Compare headers with special handling for `X-SDK-Client`
        for (key, expectedValue) in expectedHeaders {
            guard let actualValue = request.allHTTPHeaderFields?[key] else {
                XCTFail("Missing header: \(key)", file: file, line: line)
                continue
            }

            if key == "X-SDK-Client" {
                XCTAssertEqualBase64JSONStrings(actualValue, expectedValue, file: file, line: line)
            } else {
                XCTAssertEqual(actualValue, expectedValue, file: file, line: line)
            }
        }
    }
}

func XCTAssertRequestWithPublicKeyCredential(
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
        let bodyJSON = try JSON(data: XCTUnwrap(request.httpBody)) // Parse request body as JSON

        // Check for `public_key_credential`
        if let requestCredentialString = bodyJSON["public_key_credential"].string, let expectedCredentialString = expectedBody["public_key_credential"].string {
            // Parse the nested JSON strings in `public_key_credential`
            let requestCredentialJSON = JSON(parseJSON: requestCredentialString)
            let expectedCredentialJSON = JSON(parseJSON: expectedCredentialString)

            // Assert equality of the nested JSON objects
            XCTAssertEqual(
                requestCredentialJSON,
                expectedCredentialJSON,
                "The `public_key_credential` objects do not match",
                file: file,
                line: line
            )
        } else {
            XCTFail("Missing or invalid `public_key_credential` in request body", file: file, line: line)
        }
    }

    if let expectedHeaders = expectedHeaders {
        // Compare headers with special handling for `X-SDK-Client`
        for (key, expectedValue) in expectedHeaders {
            guard let actualValue = request.allHTTPHeaderFields?[key] else {
                XCTFail("Missing header: \(key)", file: file, line: line)
                continue
            }

            if key == "X-SDK-Client" {
                XCTAssertEqualBase64JSONStrings(actualValue, expectedValue, file: file, line: line)
            } else {
                XCTAssertEqual(actualValue, expectedValue, file: file, line: line)
            }
        }
    }
}

/// Helper to compare JSON strings
func XCTAssertEqualBase64JSONStrings(
    _ base64String1: String,
    _ base64String2: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        // Decode Base64 Strings
        guard let data1 = Data(base64Encoded: base64String1), let data2 = Data(base64Encoded: base64String2) else {
            XCTFail("Failed to decode Base64 strings", file: file, line: line)
            return
        }

        // Convert Data to JSON Objects
        let jsonObject1 = try JSONSerialization.jsonObject(with: data1, options: []) as? [String: Any]
        let jsonObject2 = try JSONSerialization.jsonObject(with: data2, options: []) as? [String: Any]

        // Compare JSON Objects
        // swiftlint:disable:next legacy_objc_type
        let areDictionariesEqual = NSDictionary(dictionary: jsonObject1 ?? [:]).isEqual(to: jsonObject2 ?? [:])
        XCTAssertTrue(areDictionariesEqual, "JSON objects are not equal", file: file, line: line)
    } catch {
        XCTFail("Failed to decode JSON: \(error.localizedDescription)", file: file, line: line)
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
    if value1 != value2 {
        let errorMessage =
            """
            JSON did not match:

            JSON:
            \(value1.description)

            Expected:
            \(value2.description)

            Difference:
            \(value1.difference(from: value2) ?? "No Differnce String")
            """
        XCTFail(errorMessage, file: file, line: line)
    }
}

private extension JSON {
    // swiftlint:disable:next cyclomatic_complexity
    func difference(from other: JSON?) -> String? {
        guard let other else {
            return "\(self) != \("nil")"
        }

        switch (type, other.type) {
        case (.string, .string):
            return stringValue.difference(from: other.stringValue).testDescription(descriptor: "character").map { "\(self) != \(other)\n" + $0 }
        case (.number, .number):
            return self != other ? "\(self) != \(other)" : nil
        case (.bool, .bool):
            return self != other ? "\(self) != \(other)" : nil
        case (.array, .array):
            return arrayValue.difference(from: other.arrayValue).testDescription(descriptor: "value")
        case (.dictionary, .dictionary):
            let selfKeys = dictionaryValue.keys.sorted()
            if let description = selfKeys.difference(from: other.dictionaryValue.keys.sorted()).testDescription(descriptor: "key") {
                return description
            } else {
                for key in selfKeys {
                    if let selfValue = dictionaryValue[key], let otherValue = other.dictionaryValue[key] {
                        if let description = selfValue.difference(from: otherValue) {
                            return description
                        }
                    }
                }
            }
            return nil
        case (.null, .null):
            return self != other ? "\(self) != \(other)" : nil
        case (.unknown, .unknown):
            return self != other ? "\(self) != \(other)" : nil
        default:
            return "\(self) != \(other)"
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
