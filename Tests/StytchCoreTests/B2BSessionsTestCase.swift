import Combine
@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

// swiftlint:disable multiline_function_chains

final class B2BSessionsTestCase: BaseTestCase {
    var subscriptions: Set<AnyCancellable> = []

    func testSessionsAuthenticate() async throws {
        networkInterceptor.responses { B2BAuthenticateResponse.mock }
        let parameters: StytchB2BClient.Sessions.AuthenticateParameters = .init(sessionDurationMinutes: 15)

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchB2BClient.sessions.memberSession)

        Current.sessionManager.updateSession(
            sessionType: .member(.mock),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        _ = try await StytchB2BClient.sessions.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sessions/authenticate",
            method: .post(["session_duration_minutes": 15])
        )

        XCTAssertEqual(StytchB2BClient.sessions.sessionJwt, .jwt("i'mvalidjson"))
        XCTAssertEqual(StytchB2BClient.sessions.sessionToken, .opaque("xyzasdf"))
        XCTAssertNotNil(StytchB2BClient.sessions.memberSession)
    }

    func testSessionsAttest() async throws {
        networkInterceptor.responses { B2BAuthenticateResponse.mock }

        let parameters = StytchB2BClient.Sessions.AttestParameters(
            profileId: "profile_123",
            token: "attestation_token",
            organizationId: "org_123",
            sessionJwt: "existing_jwt",
            sessionToken: "existing_token"
        )

        Current.timer = { _, _, _ in .init() }

        XCTAssertNil(StytchB2BClient.sessions.memberSession)

        _ = try await StytchB2BClient.sessions.attest(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sessions/attest",
            method: .post([
                "profile_id": "profile_123",
                "token": "attestation_token",
                "organization_id": "org_123",
                "session_jwt": "existing_jwt",
                "session_token": "existing_token",
            ])
        )

        XCTAssertEqual(StytchB2BClient.sessions.sessionJwt, .jwt("i'mvalidjson"))
        XCTAssertEqual(StytchB2BClient.sessions.sessionToken, .opaque("xyzasdf"))
        XCTAssertNotNil(StytchB2BClient.sessions.memberSession)
    }

    func testSessionsRevoke() async throws {
        networkInterceptor.responses { BasicResponse(requestId: "request_id", statusCode: 200) }
        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(
            sessionType: .member(.mock),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        XCTAssertEqual(StytchB2BClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchB2BClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        _ = try await StytchB2BClient.sessions.revoke()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/b2b/sessions/revoke", method: .post([:]))

        XCTAssertNil(StytchB2BClient.sessions.sessionJwt)
        XCTAssertNil(StytchB2BClient.sessions.sessionToken)
    }

    func testExternalSessionsUpdate() async {
        _ = try? await StytchB2BClient.sessions.revoke(parameters: .init(forceClear: true))

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

    func testSessionExchange() async throws {
        networkInterceptor.responses {
            B2BMFAAuthenticateResponse.mock
        }

        Current.timer = { _, _, _ in .init() }

        let organizationID = "org_123"
        let parameters = StytchB2BClient.Sessions.ExchangeParameters(organizationID: organizationID)
        _ = try await StytchB2BClient.sessions.exchange(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sessions/exchange",
            method: .post([
                "organization_id": JSON(stringLiteral: organizationID),
                "session_duration_minutes": 5,
                "locale": "en",
            ])
        )
    }

    func testMemberSessionsPublisherAvailable() throws {
        let expectation = XCTestExpectation(description: "onMemberSessionChange completes")
        var receivedMemberSession: MemberSession?
        var receivedDate: Date?

        StytchB2BClient.sessions.onMemberSessionChange.sink { memberSessionInfo in
            switch memberSessionInfo {
            case let .available(memberSession, lastValidatedAtDate):
                receivedMemberSession = memberSession
                receivedDate = lastValidatedAtDate
                expectation.fulfill()
            case .unavailable:
                expectation.fulfill()
            }
        }.store(in: &subscriptions)

        Current.timer = { _, _, _ in .init() }
        Current.sessionManager.updateSession(
            sessionType: .member(.mock),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedMemberSession)
        XCTAssertNotNil(receivedDate)
    }

    func testMemberSessionsPublisherUnavailable() throws {
        let expectation = XCTestExpectation(description: "onMemberSessionChange completes")

        StytchB2BClient.sessions.onMemberSessionChange.sink { sessionInfo in
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
        XCTAssertNil(StytchB2BClient.sessions.memberSession)
    }

    func testGetExpiredMemberSessionReturnsNil() throws {
        Current.timer = { _, _, _ in .init() }
        Current.sessionManager.updateSession(
            sessionType: .member(.mockWithExpiredMemberSession),
            tokens: SessionTokens(jwt: .jwt("i'm_jwt"), opaque: .opaque("opaque_all_day"))
        )

        XCTAssertNil(StytchB2BClient.sessions.memberSession)
    }
}
