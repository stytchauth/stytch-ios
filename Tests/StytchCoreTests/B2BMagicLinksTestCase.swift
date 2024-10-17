@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

final class B2BMagicLinksTestCase: BaseTestCase {
    func testEmailLoginOrSignup() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchB2BClient.MagicLinks.Email.Parameters = .init(
            organizationId: "org_123",
            emailAddress: "asdf@stytch.com",
            loginRedirectUrl: baseUrl.appendingPathComponent("login"),
            signupRedirectUrl: baseUrl.appendingPathComponent("signup"),
            loginTemplateId: "g'day",
            signupTemplateId: "mate"
        )

        XCTAssertTrue(try Current.keychainClient.get(.codeVerifierPKCE).isEmpty)

        let response = try await StytchB2BClient.magicLinks.email.loginOrSignup(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.get(.codeVerifierPKCE), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/magic_links/email/login_or_signup",
            method: .post([
                "organization_id": "org_123",
                "signup_redirect_url": "https://myapp.com/signup",
                "pkce_code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "email_address": "asdf@stytch.com",
                "login_redirect_url": "https://myapp.com/login",
                "login_template_id": "g'day",
                "signup_template_id": "mate",
            ])
        )
    }

    func testEmailDiscoverySend() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchB2BClient.MagicLinks.Email.DiscoveryParameters = .init(
            emailAddress: "asdf@stytch.com",
            discoveryRedirectUrl: baseUrl.appendingPathComponent("login"),
            loginTemplateId: "g'day",
            locale: .en
        )

        XCTAssertTrue(try Current.keychainClient.get(.codeVerifierPKCE).isEmpty)

        _ = try await StytchB2BClient.magicLinks.email.discoverySend(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/magic_links/email/discovery/send",
            method: .post([
                "discovery_redirect_url": "https://myapp.com/login",
                "pkce_code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "email_address": "asdf@stytch.com",
                "login_template_id": "g'day",
                "locale": "en",
            ])
        )
    }

    func testEmailInviteSend() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchB2BClient.MagicLinks.Email.InviteParameters = .init(
            emailAddress: "asdf@stytch.com",
            inviteRedirectUrl: baseUrl.appendingPathComponent("login"),
            inviteTemplateId: "g'day",
            locale: .en
        )

        _ = try await StytchB2BClient.magicLinks.email.inviteSend(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/magic_links/email/invite",
            method: .post([
                "email_address": "asdf@stytch.com",
                "invite_redirect_url": "https://myapp.com/login",
                "invite_template_id": "g'day",
                "locale": "en",
            ])
        )
    }

    func testAuthenticate() async throws {
        let authResponse: B2BMFAAuthenticateResponse = .mock
        networkInterceptor.responses { authResponse }
        let parameters: StytchB2BClient.MagicLinks.AuthenticateParameters = .init(
            token: "12345",
            sessionDuration: 15,
            locale: .en
        )

        try Current.keychainClient.set(String.mockPKCECodeVerifier, for: .codeVerifierPKCE)
        try Current.keychainClient.set(String.mockPKCECodeChallenge, for: .codeChallengePKCE)

        XCTAssertNotNil(try Current.keychainClient.get(.codeVerifierPKCE))

        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        let response = try await StytchB2BClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "req_123")
        XCTAssertEqual(response.member.id, authResponse.member.id)
        XCTAssertEqual(response.sessionToken, "xyzasdf")
        XCTAssertEqual(response.sessionJwt, "i'mvalidjson")
        if let responseMemberSessionExpiresAt = response.memberSession?.expiresAt, let authResponseMemberSessionExpiresAt = authResponse.memberSession?.expiresAt {
            XCTAssertTrue(Calendar.current.isDate(responseMemberSessionExpiresAt, equalTo: authResponseMemberSessionExpiresAt, toGranularity: .second))
        } else {
            XCTFail("Something went wrong, one of the member sessions in nil and should not be")
        }

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/magic_links/authenticate",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "magic_links_token": "12345", "session_duration_minutes": 15,
                "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "locale": "en",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())
    }

    func testDiscoveryAuthenticate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.MagicLinks.DiscoveryAuthenticateResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    discoveredOrganizations: [],
                    intermediateSessionToken: "IMS",
                    emailAddress: "1@2.3"
                )
            )
        }

        let parameters: StytchB2BClient.MagicLinks.DiscoveryAuthenticateParameters = .init(token: "12345")

        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.magicLinks.discoveryAuthenticate(parameters: parameters),
            StytchSDKError.missingPKCE
        )

        try Current.keychainClient.set(String.mockPKCECodeVerifier, for: .codeVerifierPKCE)
        try Current.keychainClient.set(String.mockPKCECodeChallenge, for: .codeChallengePKCE)

        XCTAssertNotNil(try Current.keychainClient.get(.codeVerifierPKCE))

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchB2BClient.magicLinks.discoveryAuthenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/magic_links/discovery/authenticate",
            method: .post(["discovery_magic_links_token": "12345", "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741"])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())
    }
}

extension B2BAuthenticateResponse {
    static let mock: Self = .init(
        requestId: "req_123",
        statusCode: 200,
        wrapped: .init(
            memberSession: .mock,
            member: .mock,
            organization: .mock,
            sessionToken: "xyzasdf",
            sessionJwt: "i'mvalidjson"
        )
    )
}

extension B2BMFAAuthenticateResponse {
    static let mock: Self = .init(
        requestId: "req_123",
        statusCode: 200,
        wrapped: .init(
            memberSession: .mock,
            memberId: "member_id_123",
            member: .mock,
            organization: .mock,
            sessionToken: "xyzasdf",
            sessionJwt: "i'mvalidjson",
            intermediateSessionToken: "cccccbgkvlhvciffckuevcevtrkjfkeiklvulgrrgvke",
            memberAuthenticated: false,
            mfaRequired: nil
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
        memberPasswordId: "",
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
            roles: ["reader"],
            memberSessionId: "mem_session_123"
        )
    }()

    static let mockWithAdminRole: Self = {
        let refDate = Date()
        return .init(
            organizationId: Organization.mock.id,
            memberId: Member.mock.id,
            startedAt: refDate,
            lastAccessedAt: refDate,
            expiresAt: refDate.advanced(by: 60 * 60 * 24),
            authenticationFactors: [],
            customClaims: nil,
            roles: ["organization_admin"],
            memberSessionId: "mem_session_123"
        )
    }()

    static let mockWithExpiredMemberSession: Self = {
        .init(
            organizationId: Organization.mock.id,
            memberId: Member.mock.id,
            startedAt: Date.distantPast,
            lastAccessedAt: Date.distantPast,
            expiresAt: Date.distantPast,
            authenticationFactors: [],
            customClaims: nil,
            roles: ["organization_admin"],
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
