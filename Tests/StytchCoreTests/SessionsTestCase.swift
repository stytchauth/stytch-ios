import XCTest
@testable import StytchCore

final class SessionsTestCase: BaseTestCase {
    func testSessionsAuthenticate() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }
        let parameters: StytchClient.StytchClientSessions.AuthenticateParameters = .init(sessionDurationMinutes: 15)

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchClient.sessions.session)

        Current.sessionStorage.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day")),
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        _ = try await StytchClient.sessions.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/sessions/authenticate",
            method: .post(["session_duration_minutes": 15])
        )

        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertNotNil(StytchClient.sessions.session)
    }

    func testSessionsRevoke() async throws {
        networkInterceptor.responses { BasicResponse(requestId: "request_id", statusCode: 200) }
        Current.timer = { _, _, _ in .init() }

        Current.sessionStorage.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day")),
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        _ = try await StytchClient.sessions.revoke()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/sessions/revoke", method: .post([:]))

        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
    }

    func testSessionRevokeNetworkError() async throws {
        networkInterceptor.responses {
            StytchError(name: "fake_error", message: "I'm a mock error")
            StytchError(name: "fake_error", message: "I'm a mock error")
        }
        Current.timer = { _, _, _ in .init() }

        Current.sessionStorage.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day")),
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        await XCTAssertThrowsErrorAsync(
            try await StytchClient.sessions.revoke(),
            StytchError(name: "fake_error", message: "I'm a mock error")
        )

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/sessions/revoke", method: .post([:]))

        XCTAssertNotNil(StytchClient.sessions.sessionJwt)
        XCTAssertNotNil(StytchClient.sessions.sessionToken)

        await XCTAssertThrowsErrorAsync(
            try await StytchClient.sessions.revoke(parameters: .init(forceClear: true)),
            StytchError(name: "fake_error", message: "I'm a mock error")
        )

        try XCTAssertRequest(networkInterceptor.requests[1], urlString: "https://api.stytch.com/sdk/v1/sessions/revoke", method: .post([:]))

        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
    }

    func testExternalSessionsUpdate() {
        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        if let tokens = SessionTokens(jwt: .jwt("jwt"), opaque: .opaque("token")) {
            StytchClient.sessions.update(sessionTokens: tokens)
            XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("token"))
            XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt"))
        } else {
            XCTFail("SessionTokens should not be nil")
        }
    }

    func testIntermediateSessionToken() {
        Current.timer = { _, _, _ in .init() }

        // Given we call update session with valid member session and tokens
        Current.sessionStorage.updateSession(
            sessionType: .member(.mock),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day")),
            hostUrl: URL(string: "https://url.com")
        )

        // And it correctly applies the values
        XCTAssertNotNil(Current.sessionStorage.sessionToken)
        XCTAssertNotNil(Current.sessionStorage.sessionJwt)
        XCTAssertNotNil(Current.sessionStorage.memberSession)
        XCTAssertNil(Current.sessionStorage.intermediateSessionToken)

        // When we call update session with a IST value
        Current.sessionStorage.updateSession(intermediateSessionToken: "ist")

        // Then our IST is not nil but the other values are
        XCTAssertNil(Current.sessionStorage.sessionToken)
        XCTAssertNil(Current.sessionStorage.sessionJwt)
        XCTAssertNil(Current.sessionStorage.memberSession)
        XCTAssertNotNil(Current.sessionStorage.intermediateSessionToken)
    }
}
