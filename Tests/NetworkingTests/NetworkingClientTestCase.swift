import NetworkingTestSupport
import XCTest
@testable import Networking

final class NetworkingClientTestCase: XCTestCase {
    private var networkingClient: NetworkingClient = .mock(returning: .success(.init()))

    func testCustomHeaders() throws {
        let headers = ["CUSTOM": "HEADER"]
        try verifyRequest(
            onClientCreate: { $0.headerProvider = { headers } },
            onPerformRequest: { request, line in
                XCTAssertEqual(request.httpMethod, "GET", line: line)
            }
        )
    }

    func testUrl() throws {
        let url = try XCTUnwrap(URL(string: "https://stytch.com?blah=blah"))
        try verifyRequest(url: url) { request, line in
            XCTAssertEqual(request.url, url, line: line)
        }
    }

    func testMethodGet() throws {
        try verifyRequest { request, line in
            XCTAssertEqual(request.httpMethod, "GET", line: line)
        }
    }

    func testMethodPost() throws {
        let testString = "test_string"
        try verifyRequest(.post(.init(testString.utf8))) { request, line in
            XCTAssertEqual(request.httpMethod, "POST", line: line)
            XCTAssertEqual(request.httpBody.map { String(data: $0, encoding: .utf8) }, testString, line: line)
        }
    }

    func testMethodPut() throws {
        let testString = "test_string"
        try verifyRequest(.put(.init(testString.utf8))) { request, line in
            XCTAssertEqual(request.httpMethod, "PUT", line: line)
            XCTAssertEqual(request.httpBody.map { String(data: $0, encoding: .utf8) }, testString, line: line)
        }
    }

    func testMethodDelete() throws {
        try verifyRequest(.delete) { request, line in
            XCTAssertEqual(request.httpMethod, "DELETE", line: line)
        }
    }

    private func verifyRequest(
        _ method: NetworkingClient.Method = .get,
        url: URL? = nil,
        line: UInt = #line,
        onClientCreate: ((NetworkingClient) -> Void)? = nil,
        onPerformRequest: @escaping (_ request: URLRequest, _ line: UInt) -> Void
    ) throws {
        let expectation = expectation(description: "Request handled")
        networkingClient = .init { request, _ in
            onPerformRequest(request, line)
            expectation.fulfill()
            return .init(dataTask: nil)
        }
        onClientCreate?(networkingClient)
        networkingClient.performRequest(
            method,
            url: try url ?? XCTUnwrap(URL(string: "https://www.stytch.com"))
        ) { _ in
            XCTFail("Completion should not be called using this mock", line: line)
        }
        wait(for: [expectation], timeout: 1)
    }
}
