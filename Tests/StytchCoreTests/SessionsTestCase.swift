import XCTest
@testable import StytchCore

final class SessionsTestCase: BaseTestCase {
    func testSessionsAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))

        let parameters: StytchClient.Sessions.AuthenticateParameters = .init(sessionDuration: 15)

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchClient.sessions.session)

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        _ = try await StytchClient.sessions.authenticate(parameters: parameters)

        try XCTAssertRequest(
            request,
            urlString: "https://web.stytch.com/sdk/v1/sessions/authenticate",
            method: .post,
            bodyEquals: ["session_duration_minutes": 15]
        )

        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertNotNil(StytchClient.sessions.session)
    }

    func testSessionsRevoke() async throws {
        let container: DataContainer<BasicResponse> = .init(data: .init(requestId: "request_id", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))

        Current.timer = { _, _, _ in .init() }

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        _ = try await StytchClient.sessions.revoke()

        try XCTAssertRequest(request, urlString: "https://web.stytch.com/sdk/v1/sessions/revoke", method: .post, bodyEquals: [:])

        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
    }

    func testExternalSessionsUpdate() {
        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        StytchClient.sessions.update(sessionTokens: [.opaque("token"), .jwt("jwt")])

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("token"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt"))
    }
}
