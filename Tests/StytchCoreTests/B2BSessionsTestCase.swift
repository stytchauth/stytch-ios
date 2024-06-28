import XCTest
@testable import StytchCore

final class B2BSessionsTestCase: BaseTestCase {
    func testSessionsAuthenticate() async throws {
        networkInterceptor.responses { B2BAuthenticateResponse.mock }
        let parameters: Sessions<B2BAuthenticateResponse>.AuthenticateParameters = .init(sessionDuration: 15)

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchB2BClient.sessions.memberSession)

        Current.sessionStorage.updateSession(
            .user(.mock(userId: "i_am_user")),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        _ = try await StytchB2BClient.sessions.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/sessions/authenticate",
            method: .post(["session_duration_minutes": 15])
        )

        XCTAssertEqual(StytchB2BClient.sessions.sessionJwt, .jwt("i'mvalidjson"))
        XCTAssertEqual(StytchB2BClient.sessions.sessionToken, .opaque("xyzasdf"))
        XCTAssertNotNil(StytchB2BClient.sessions.memberSession)
    }

    func testSessionsRevoke() async throws {
        networkInterceptor.responses { BasicResponse(requestId: "request_id", statusCode: 200) }
        Current.timer = { _, _, _ in .init() }

        Current.sessionStorage.updateSession(
            .user(.mock(userId: "i_am_user")),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        XCTAssertEqual(StytchB2BClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchB2BClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        _ = try await StytchB2BClient.sessions.revoke()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/b2b/sessions/revoke", method: .post([:]))

        XCTAssertNil(StytchB2BClient.sessions.sessionJwt)
        XCTAssertNil(StytchB2BClient.sessions.sessionToken)
    }

    func testExternalSessionsUpdate() {
        XCTAssertNil(StytchB2BClient.sessions.sessionToken)
        XCTAssertNil(StytchB2BClient.sessions.sessionJwt)

        if let tokens = SessionTokens(jwt: .jwt("jwt"), opaque: .opaque("token")) {
            StytchB2BClient.sessions.update(sessionTokens: tokens)
            XCTAssertEqual(StytchB2BClient.sessions.sessionToken, .opaque("token"))
            XCTAssertEqual(StytchB2BClient.sessions.sessionJwt, .jwt("jwt"))
        } else {
            XCTFail("SessionTokens should not be nil")
        }
    }
}
