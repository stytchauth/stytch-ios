import XCTest
import Networking

final class NetworkingClientTestCase: XCTestCase {
    private var networkingClient: NetworkingClient = .init(dataTaskClient: .mock(returning: .success(.init())))

    func testCustomHeaders() throws {
        let headers: [String: String] = ["CUSTOM": "HEADER"]
        try verifyRequest(
            onClientCreate: { $0.headerProvider = { headers } },
            onPerformRequest: { request in
                XCTAssertEqual(request.httpMethod, "GET")
            }
        )
    }

    func testUrl() throws {
        let url = try XCTUnwrap(URL(string: "https://stytch.com?blah=blah"))
        try verifyRequest(url: url) { request in
            XCTAssertEqual(request.url, url)
        }
    }

    func testMethodGet() throws {
        try verifyRequest { request in
            XCTAssertEqual(request.httpMethod, "GET")
        }
    }

    func testMethodPost() throws {
        let testString = "test_string"
        try verifyRequest(.post(.init(testString.utf8))) { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBody.map { String(data: $0, encoding: .utf8) }, testString)
        }
    }

    func testMethodPut() throws {
        let testString = "test_string"
        try verifyRequest(.put(.init(testString.utf8))) { request in
            XCTAssertEqual(request.httpMethod, "PUT")
            XCTAssertEqual(request.httpBody.map { String(data: $0, encoding: .utf8) }, testString)
        }
    }

    func testMethodDelete() throws {
        try verifyRequest(.delete) { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
        }
    }

    private func verifyRequest(
        _ method: NetworkingClient.Method = .get,
        url: URL? = nil,
        line: UInt = #line,
        onClientCreate: ((NetworkingClient) -> Void)? = nil,
        onPerformRequest: @escaping (URLRequest) -> Void
    ) throws {
        let expectation = self.expectation(description: "Request handled")
        networkingClient = .init(dataTaskClient: .init { request, _, _ in
            onPerformRequest(request)
            expectation.fulfill()
            return .init(dataTask: nil)
        })
        onClientCreate?(networkingClient)
        networkingClient.performRequest(
            method,
            url: try url ?? XCTUnwrap(URL(string: "https://www.stytch.com"))
        ) { _ in
            XCTFail("Completion should not be called using this mock")
        }
        wait(for: [expectation], timeout: 1)
    }
}
