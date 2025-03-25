import XCTest
@testable import StytchCore

final class MagicLinksTestCase: BaseTestCase {
    func testMagicLinksEmailLoginOrCreate() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30,
            loginTemplateId: "g'day",
            signupMagicLinkUrl: baseUrl.appendingPathComponent("signup"),
            signupExpiration: 30,
            signupTemplateId: "mate",
            locale: .en
        )

        XCTAssertTrue(try Current.keychainClient.getQueryResults(.codeVerifierPKCE).isEmpty)

        let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.getStringValue(.codeVerifierPKCE), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/magic_links/email/login_or_create",
            method: .post([
                "signup_magic_link_url": "https://myapp.com/signup",
                "code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "signup_expiration_minutes": 30,
                "email": "asdf@stytch.com",
                "login_magic_link_url": "https://myapp.com/login",
                "login_expiration_minutes": 30,
                "login_template_id": "g'day",
                "signup_template_id": "mate",
                "locale": "en",
            ])
        )
    }

    func testMagicLinksSendWithNoSession() async throws {
        networkInterceptor.responses { BasicResponse(requestId: "1234", statusCode: 200) }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30,
            loginTemplateId: "hello",
            locale: .en
        )

        XCTAssertFalse(Current.sessionManager.hasValidSessionToken)
        XCTAssertTrue(try Current.keychainClient.getQueryResults(.codeVerifierPKCE).isEmpty)

        let response = try await StytchClient.magicLinks.email.send(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.getStringValue(.codeVerifierPKCE), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/magic_links/email/send/primary",
            method: .post([
                "code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "email": "asdf@stytch.com",
                "login_magic_link_url": "https://myapp.com/login",
                "login_expiration_minutes": 30,
                "login_template_id": "hello",
                "locale": "en",
            ])
        )
    }

    func testMagicLinksSendWithActiveSession() async throws {
        networkInterceptor.responses { BasicResponse(requestId: "1234", statusCode: 200) }
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30,
            locale: .en
        )

        try Current.keychainClient.setStringValue("123", for: .sessionToken)

        XCTAssertTrue(Current.sessionManager.hasValidSessionToken)
        XCTAssertTrue(try Current.keychainClient.getQueryResults(.codeVerifierPKCE).isEmpty)

        let response = try await StytchClient.magicLinks.email.send(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.getStringValue(.codeVerifierPKCE), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/magic_links/email/send/secondary",
            method: .post([
                "code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "email": "asdf@stytch.com",
                "login_magic_link_url": "https://myapp.com/login",
                "login_expiration_minutes": 30,
                "locale": "en",
            ])
        )
    }

    func testMagicLinksAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        networkInterceptor.responses { authResponse }
        let parameters: StytchClient.MagicLinks.AuthenticateParameters = .init(
            token: "12345",
            sessionDuration: 15
        )

        await XCTAssertThrowsErrorAsync(
            try await StytchClient.magicLinks.authenticate(parameters: parameters),
            StytchSDKError.missingPKCE
        )

        try Current.keychainClient.setStringValue(String.mockPKCECodeVerifier, for: .codeVerifierPKCE)
        try Current.keychainClient.setStringValue(String.mockPKCECodeChallenge, for: .codeChallengePKCE)

        XCTAssertNotNil(try Current.keychainClient.getStringValue(.codeVerifierPKCE))

        Current.timer = { _, _, _ in .init() }

        let response = try await StytchClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.user.id, authResponse.user.id)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .second))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/magic_links/authenticate",
            method: .post(["token": "12345", "session_duration_minutes": 15, "code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741"])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.emailMagicLinks)
    }
}
