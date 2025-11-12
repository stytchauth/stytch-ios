import Combine
import XCTest
@testable import StytchCore

// swiftlint:disable multiline_function_chains

final class SessionManagerTestCase: BaseTestCase {
    var subscriptions: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        subscriptions = []
    }

    func testSessionsAuthenticate() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }
        let parameters: StytchClient.Sessions.AuthenticateParameters = .init(sessionDurationMinutes: 15)

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchClient.sessions.session)

        Current.sessionManager.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
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

    func testSessionsAttest() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }
        let parameters = StytchClient.Sessions.AttestParameters(
            profileId: "profile_123",
            token: "attestation_token",
            sessionDurationMinutes: 30,
            sessionJwt: "existing_jwt",
            sessionToken: "existing_token"
        )

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchClient.sessions.session)

        _ = try await StytchClient.sessions.attest(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/sessions/attest",
            method: .post([
                "profile_id": "profile_123",
                "token": "attestation_token",
                "session_duration_minutes": 30,
                "session_jwt": "existing_jwt",
                "session_token": "existing_token",
            ])
        )

        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertNotNil(StytchClient.sessions.session)
    }

    func testSessionsRevoke() async throws {
        networkInterceptor.responses { BasicResponse(requestId: "request_id", statusCode: 200) }
        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
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

        Current.sessionManager.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
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

    func testExternalSessionsUpdate() async {
        _ = try? await StytchClient.sessions.revoke(parameters: .init(forceClear: true))

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
        Current.sessionManager.updateSession(
            sessionType: .member(.mock),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        // And it correctly applies the values
        XCTAssertNotNil(Current.sessionManager.sessionToken)
        XCTAssertNotNil(Current.sessionManager.sessionJwt)
        XCTAssertNotNil(Current.memberSessionStorage.object)
        XCTAssertNil(Current.sessionManager.intermediateSessionToken)

        // When we call update session with a IST value
        Current.sessionManager.updateSession(intermediateSessionToken: "ist")

        // Then our IST is not nil but the other values are
        XCTAssertNil(Current.sessionManager.sessionToken)
        XCTAssertNil(Current.sessionManager.sessionJwt)
        XCTAssertNil(Current.memberSessionStorage.object)
        XCTAssertNotNil(Current.sessionManager.intermediateSessionToken)
    }

    func testSessionsPublisherAvailable() throws {
        let expectation = XCTestExpectation(description: "onSessionChange completes")
        var receivedSession: Session?
        var receivedDate: Date?

        StytchClient.sessions.onSessionChange.sink { sessionInfo in
            switch sessionInfo {
            case let .available(session, lastValidatedAtDate):
                receivedSession = session
                receivedDate = lastValidatedAtDate
                expectation.fulfill()
            case .unavailable:
                break
            }
        }.store(in: &subscriptions)

        Current.timer = { _, _, _ in .init() }
        Current.sessionManager.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedSession)
        XCTAssertNotNil(receivedDate)
    }

    func testSessionsPublisherUnavailable() throws {
        let expectation = XCTestExpectation(description: "onSessionChange completes")

        StytchClient.sessions.onSessionChange.sink { sessionInfo in
            switch sessionInfo {
            case .available:
                break
            case .unavailable:
                expectation.fulfill()
            }
        }.store(in: &subscriptions)

        Current.timer = { _, _, _ in .init() }
        Current.sessionManager.updateSession(
            sessionType: nil,
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(StytchClient.sessions.session)
    }

    func testGetExpiredSessionReturnsNil() throws {
        Current.timer = { _, _, _ in .init() }
        Current.sessionManager.updateSession(
            sessionType: .user(.mockWithExpiredSession(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        XCTAssertNil(StytchClient.sessions.session)
    }

    func testSessionClearsForUnrecoverable401Error() async throws {
        // .unauthorizedCredentials is a "Unrecoverable" error as defined by StytchAPIError.isUnrecoverableErrorType
        let error = StytchAPIError(statusCode: 401, errorType: .unauthorizedCredentials, errorMessage: "")
        networkInterceptor.responses {
            error
        }

        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        XCTAssertNotNil(Current.sessionManager.sessionToken)
        XCTAssertNotNil(Current.sessionManager.sessionJwt)
        XCTAssertNotNil(Current.sessionStorage.object)

        let parameters: StytchClient.Sessions.AuthenticateParameters = .init(sessionDurationMinutes: 15)

        await XCTAssertThrowsErrorAsync(
            _ = try await StytchClient.sessions.authenticate(parameters: parameters),
            error
        )

        XCTAssertNil(Current.sessionManager.sessionToken)
        XCTAssertNil(Current.sessionManager.sessionJwt)
        XCTAssertNil(Current.sessionStorage.object)
    }

    func testSessionDoesNotClearsForRecoverable401Error() async throws {
        // .userNotFound is not a "Unrecoverable" error as it is not defined by StytchAPIError.isUnrecoverableErrorType
        let error = StytchAPIError(statusCode: 401, errorType: .userNotFound, errorMessage: "")
        networkInterceptor.responses {
            error
        }

        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(
            sessionType: .user(.mock(userId: "i_am_user")),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        XCTAssertNotNil(Current.sessionManager.sessionToken)
        XCTAssertNotNil(Current.sessionManager.sessionJwt)
        XCTAssertNotNil(Current.sessionStorage.object)

        let parameters: StytchClient.Sessions.AuthenticateParameters = .init(sessionDurationMinutes: 15)

        await XCTAssertThrowsErrorAsync(
            _ = try await StytchClient.sessions.authenticate(parameters: parameters),
            error
        )

        XCTAssertNotNil(Current.sessionManager.sessionToken)
        XCTAssertNotNil(Current.sessionManager.sessionJwt)
        XCTAssertNotNil(Current.sessionStorage.object)
    }
}
