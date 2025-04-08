import XCTest
@testable import StytchCore

final class DeeplinkHandlerTestCase: BaseTestCase {
    func testHandleUrl() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }

        let notHandledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345"))

        switch try await StytchClient.handle(url: notHandledUrl, sessionDurationMinutes: 30) {
        case .handled:
            XCTFail("expected to be nothandled")
        case .notHandled, .manualHandlingRequired:
            break
        }

        let handledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345&stytch_token_type=magic_links"))

        await XCTAssertThrowsErrorAsync(
            try await StytchClient.handle(url: handledUrl),
            StytchSDKError.missingPKCE
        )

        try Current.keychainClient.setStringValue(String.mockPKCECodeVerifier, for: .codeVerifierPKCE)
        try Current.keychainClient.setStringValue(String.mockPKCECodeChallenge, for: .codeChallengePKCE)

        Current.timer = { _, _, _ in .init() }

        switch try await StytchClient.handle(url: handledUrl, sessionDurationMinutes: 30) {
        case let .handled(response):
            switch response {
            case let .auth(responseData):
                XCTAssertEqual(responseData.sessionJwt, "jwt_for_me")
                XCTAssertEqual(responseData.session.authenticationFactors.count, 1)
            case let .oauth(responseData):
                XCTAssertEqual(responseData.sessionJwt, "jwt_for_me")
                XCTAssertEqual(responseData.session.authenticationFactors.count, 1)
            }
        case .notHandled, .manualHandlingRequired:
            XCTFail("expected to be handled")
        }
    }
}
