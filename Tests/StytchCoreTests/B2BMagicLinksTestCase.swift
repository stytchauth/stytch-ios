import XCTest
@testable import StytchCore

final class B2BMagicLinksTestCase: BaseTestCase {
    func testMagicLinksEmailLoginOrSignup() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchB2BClient.MagicLinks.Email.Parameters = .init(
            organizationId: "org_123",
            email: "asdf@stytch.com",
            loginRedirectUrl: baseUrl.appendingPathComponent("login"),
            signupRedirectUrl: baseUrl.appendingPathComponent("signup"),
            loginTemplateId: "g'day",
            signupTemplateId: "mate"
        )

        XCTAssertTrue(try Current.keychainClient.get(.emlPKCECodeVerifier).isEmpty)

        let response = try await StytchB2BClient.magicLinks.email.loginOrSignup(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.get(.emlPKCECodeVerifier), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/magic_links/email/login_or_signup",
            method: .post([
                "organization_id": "org_123",
                "pkce_code_challenge_method": "S256",
                "signup_redirect_url": "https://myapp.com/signup",
                "pkce_code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "email": "asdf@stytch.com",
                "login_redirect_url": "https://myapp.com/login",
                "login_template_id": "g'day",
                "signup_template_id": "mate",
            ])
        )
    }

    func testMagicLinksAuthenticate() async throws {
        let authResponse: B2BAuthenticateResponse = .mock
        networkInterceptor.responses { authResponse }
        let parameters: StytchB2BClient.MagicLinks.AuthenticateParameters = .init(
            token: "12345",
            sessionDuration: 15
        )

        await XCTAssertThrowsErrorAsync(try await StytchB2BClient.magicLinks.authenticate(parameters: parameters))

        try Current.keychainClient.set(String.mockPKCECodeVerifier, for: .emlPKCECodeVerifier)

        XCTAssertNotNil(try Current.keychainClient.get(.emlPKCECodeVerifier))

        Current.timer = { _, _, _ in .init() }

        let response = try await StytchB2BClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "req_123")
        XCTAssertEqual(response.member.id, authResponse.member.id)
        XCTAssertEqual(response.sessionToken, "xyzasdf")
        XCTAssertEqual(response.sessionJwt, "i'mvalidjson")
        XCTAssertTrue(Calendar.current.isDate(response.memberSession.expiresAt, equalTo: authResponse.memberSession.expiresAt, toGranularity: .nanosecond))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/magic_links/authenticate",
            method: .post(["magic_links_token": "12345", "session_duration_minutes": 15, "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741"])
        )
    }
}

extension B2BAuthenticateResponse {
    static let mock: Self = .init(
        requestId: "req_123",
        statusCode: 200,
        wrapped: .init(
            memberSession: .mock,
            member: .mock,
            sessionToken: "xyzasdf",
            sessionJwt: "i'mvalidjson"
        )
    )
}

extension Member {
    static let mock: Self = .init(
        organizationId: Organization.mock.id,
        emailAddress: "email@example.com",
        status: .active,
        name: "First Middle Last",
        ssoRegistrations: [],
        trustedMetadata: [:],
        untrustedMetadata: [:],
        memberId: "member_1234"
    )
}

extension MemberSession {
    static let mock: Self = {
        let refDate = Date()
        return .init(
            organizationId: Organization.mock.id,
            memberId: Member.mock.id,
            startedAt: refDate,
            lastAccessedAt: refDate,
            expiresAt: refDate.advanced(by: 60 * 60 * 24),
            authenticationFactors: [],
            customClaims: nil,
            memberSessionId: "mem_session_123"
        )
    }()
}

extension Organization {
    static let mock: Self = .init(
        name: "I am Org",
        slug: "org_slug",
        logoUrl: nil,
        trustedMetadata: [:],
        organizationId: "org_123"
    )
}
