import XCTest
@testable import StytchCore

final class DeeplinkHandlerTestCase: BaseTestCase {
    func testHandleUrl() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .mock(returning: .success(data))

        let notHandledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345"))

        switch try await StytchClient.handle(url: notHandledUrl, sessionDuration: 30) {
        case .handled:
            XCTFail("expected to be nothandled")
        case .notHandled, .manualHandlingRequired:
            break
        }

        let handledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345&stytch_token_type=magic_links"))

        await XCTAssertThrowsErrorAsync(try await StytchClient.handle(url: handledUrl))

        try Current.keychainClient.set(String.mockPKCECodeVerifier, for: .emlPKCECodeVerifier)

        Current.timer = { _, _, _ in .init() }

        switch try await StytchClient.handle(url: handledUrl, sessionDuration: 30) {
        case let .handled(response):
            XCTAssertEqual(response.sessionJwt, "jwt_for_me")
            XCTAssertEqual(response.session.authenticationFactors.count, 1)
        case .notHandled, .manualHandlingRequired:
            XCTFail("expected to be handled")
        }
    }
}
