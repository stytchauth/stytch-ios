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

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        let response = try await StytchClient.sessions.authenticate(parameters: parameters)

        XCTAssertEqual(response.user.id, authResponse.user.id)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/sessions/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"session_duration_minutes\":15}".utf8))

        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
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

        let response = try await StytchClient.sessions.revoke()
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "request_id")

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/sessions/revoke")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{}".utf8))

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
