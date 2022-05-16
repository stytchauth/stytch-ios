import XCTest
@testable import StytchCore

final class StytchClientTestCase: BaseTestCase {
    func testGet() throws {
        var request: URLRequest?
        let data = try Current.jsonEncoder.encode(DataContainer(data: "Hello, World!"))
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        // Configure the client after setting the networking client, so the headers are passed to the request
        StytchClient.configure(publicToken: "xyz", hostUrl: try XCTUnwrap(URL(string: "https://myapp.com")))
        let expectation = expectation(description: "request_complete")
        var response: String?
        StytchClient.get(endpoint: .init(path: "doesnt_matter")) { (result: Result<String, Error>) in
            switch result {
            case let .success(string):
                response = string
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/doesnt_matter")
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(
            request?.allHTTPHeaderFields,
            [
                "Content-Type": "application/json",
                "X-SDK-Client": try Current.clientInfo.base64EncodedString(),
                "Authorization": "Basic eHl6Onh5eg==",
            ]
        )

        XCTAssertEqual(response, "Hello, World!")
    }
}
