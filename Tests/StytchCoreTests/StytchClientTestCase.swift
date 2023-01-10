import XCTest
@testable import StytchCore

final class StytchClientTestCase: BaseTestCase {
    func testGet() async throws {
        networkInterceptor.responses { "Hello, World!" }
        // Configure the client after setting the networking client, so the headers are passed to the request
        StytchClient.configure(publicToken: "xyz", hostUrl: try XCTUnwrap(URL(string: "https://myapp.com")))
        let response: String? = try await StytchClient.router.get(route: .sessions(.authenticate))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/sessions/authenticate", method: .get, headers: [
            "Content-Type": "application/json",
            "X-SDK-Client": try Current.clientInfo.base64EncodedString(),
            "Authorization": "Basic eHl6Onh5eg==",
        ])

        XCTAssertEqual(response, "Hello, World!")
    }
}
