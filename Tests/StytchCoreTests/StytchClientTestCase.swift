import XCTest
@testable import StytchCore

final class StytchClientTestCase: BaseTestCase {
    func testGet() async throws {
        networkInterceptor.responses { "Hello, World!" }
        // Configure the client after setting the networking client, so the headers are passed to the request
        StytchClient.configure(configuration: .init(publicToken: "xyz", defaultSessionDuration: 5, hostUrl: try XCTUnwrap(URL(string: "https://myapp.com"))))
        let response: String? = try await StytchClient.router.get(route: .sessions(.authenticate))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/sessions/authenticate", method: .get, headers: [
            "Content-Type": "application/json",
            "X-SDK-Client": try Current.clientInfo.base64EncodedString(encoder: Current.jsonEncoder),
            "Authorization": "Basic eHl6Onh5eg==",
        ])

        XCTAssertEqual(response, "Hello, World!")
    }
}
