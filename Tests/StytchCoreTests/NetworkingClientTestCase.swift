import XCTest
@testable import StytchCore

final class NetworkingClientTestCase: XCTestCase {
    func testUrl() async throws {
        let url = try XCTUnwrap(URL(string: "https://stytch.com?blah=blah"))
        try await verifyRequest(url: url) { request, line in
            XCTAssertEqual(request.url, url, line: line)
        }
    }

    func testMethodGet() async throws {
        try await verifyRequest { request, line in
            XCTAssertEqual(request.httpMethod, "GET", line: line)
        }
    }

    func testMethodPost() async throws {
        let testString = "test_string"
        try await verifyRequest(.post(.init(testString.utf8))) { request, line in
            XCTAssertEqual(request.httpMethod, "POST", line: line)
            XCTAssertEqual(request.httpBody.map { String(data: $0, encoding: .utf8) }, testString, line: line)
        }
    }

    func testMethodPut() async throws {
        let testString = "test_string"
        try await verifyRequest(.put(.init(testString.utf8))) { request, line in
            XCTAssertEqual(request.httpMethod, "PUT", line: line)
            XCTAssertEqual(request.httpBody.map { String(data: $0, encoding: .utf8) }, testString, line: line)
        }
    }

    func testMethodDelete() async throws {
        try await verifyRequest(.delete) { request, line in
            XCTAssertEqual(request.httpMethod, "DELETE", line: line)
        }
    }

    private func verifyRequest(
        _ method: HTTPMethod = .get,
        url: URL? = nil,
        line _: UInt = #line,
        onPerformRequest: @escaping (_ request: URLRequest, _ line: UInt) -> Void
    ) async throws {
        let networkingClient = NetworkingClientMock()
        networkingClient.setup(onPerformRequest: onPerformRequest)

        _ = try await networkingClient.performRequest(
            method: method,
            url: try url ?? XCTUnwrap(URL(string: "https://www.stytch.com")),
            useDFPPA: false
        )
    }
}

private class NetworkingClientMock: NetworkingClient {
    var dfpEnabled: Bool = false
    var dfpAuthMode: DFPProtectedAuthMode = .observation

    var line: UInt?
    var onPerformRequest: ((_ request: URLRequest, _ line: UInt) -> Void)?

    func configureDFP(dfpEnabled: Bool, dfpAuthMode: DFPProtectedAuthMode?) {
        self.dfpEnabled = dfpEnabled
        self.dfpAuthMode = dfpAuthMode ?? .observation
    }

    func setup(line: UInt = #line, onPerformRequest: @escaping (_ request: URLRequest, _ line: UInt) -> Void) {
        self.line = line
        self.onPerformRequest = onPerformRequest
    }

    func handleRequest(request: URLRequest, useDFPPA _: Bool) async throws -> (Data, HTTPURLResponse) {
        // swiftlint:disable:next force_unwrapping
        onPerformRequest?(request, line!)
        return (Data(), HTTPURLResponse())
    }
}
