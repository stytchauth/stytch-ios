import XCTest
@testable import StytchCore

final class NetworkingClientTestCase: XCTestCase {
    private var networkingClient: NetworkingClient = .mock(returning: .success(.init()))

    func testCustomHeaders() async throws {
        let headers = ["CUSTOM": "HEADER"]
        try await verifyRequest(
            onClientCreate: { $0.headerProvider = { headers } },
            onPerformRequest: { request, line in
                XCTAssertEqual(request.httpMethod, "GET", line: line)
            }
        )
    }

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

    func testMockNetworkingClient() async throws {
        StytchClient.configure(
            publicToken: "xyz",
            hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))
        )
        let container: DataContainer<StytchClient.OneTimePasscodes.OTPResponse> = .init(
            data: .init(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(methodId: "method_id_1234")
            )
        )
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .mock(returning: .success(data))
        let response: StytchClient.OneTimePasscodes.OTPResponse = try await StytchClient.router.get(route: .otps(.authenticate))
        XCTAssertEqual(response.methodId, "method_id_1234")
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.statusCode, 200)
    }

    private func verifyRequest(
        _ method: NetworkingClient.Method = .get,
        url: URL? = nil,
        line: UInt = #line,
        onClientCreate: ((NetworkingClient) -> Void)? = nil,
        onPerformRequest: @escaping (_ request: URLRequest, _ line: UInt) -> Void
    ) async throws {
        networkingClient = .init { request in
            onPerformRequest(request, line)
            return (.init(), .init())
        }
        onClientCreate?(networkingClient)
        _ = try await networkingClient.performRequest(
            method,
            url: try url ?? XCTUnwrap(URL(string: "https://www.stytch.com"))
        )
    }
}
