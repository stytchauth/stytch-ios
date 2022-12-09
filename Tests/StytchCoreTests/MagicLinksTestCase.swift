import XCTest
@testable import StytchCore

final class MagicLinksTestCase: BaseTestCase {
    func testMagicLinksEmailLoginOrCreate() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.LoginOrCreateParameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30,
            signupMagicLinkUrl: baseUrl.appendingPathComponent("signup"),
            signupExpiration: 30
        )

        XCTAssertTrue(try Current.keychainClient.get(.emlPKCECodeVerifier).isEmpty)

        let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.get(.emlPKCECodeVerifier), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/magic_links/email/login_or_create")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"code_challenge_method\":\"S256\",\"signup_magic_link_url\":\"https:\\/\\/myapp.com\\/signup\",\"code_challenge\":\"V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8\",\"signup_expiration_minutes\":30,\"email\":\"asdf@stytch.com\",\"login_magic_link_url\":\"https:\\/\\/myapp.com\\/login\",\"login_expiration_minutes\":30}".utf8))
    }

    func testMagicLinksSendWithNoSession() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.SendParameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30
        )

        XCTAssertFalse(Current.sessionStorage.activeSessionExists)

        XCTAssertTrue(try Current.keychainClient.get(.emlPKCECodeVerifier).isEmpty)

        let response = try await StytchClient.magicLinks.email.send(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.get(.emlPKCECodeVerifier), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            request,
            urlString: "https://web.stytch.com/sdk/v1/magic_links/email/send/primary",
            method: .post,
            bodyContains: [
                ("code_challenge_method", "S256"),
                ("code_challenge", "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8"),
                ("email", "asdf@stytch.com"),
                ("login_magic_link_url", "https://myapp.com/login"),
                ("login_expiration_minutes", 30),
            ]
        )
    }

    func testMagicLinksSendWithActiveSession() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.SendParameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30
        )

        try Current.keychainClient.set("123", for: .sessionToken)

        XCTAssertTrue(Current.sessionStorage.activeSessionExists)

        XCTAssertTrue(try Current.keychainClient.get(.emlPKCECodeVerifier).isEmpty)

        let response = try await StytchClient.magicLinks.email.send(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        XCTAssertEqual(try Current.keychainClient.get(.emlPKCECodeVerifier), "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741")

        try XCTAssertRequest(
            request,
            urlString: "https://web.stytch.com/sdk/v1/magic_links/email/send/secondary",
            method: .post,
            bodyContains: [
                ("code_challenge_method", "S256"),
                ("code_challenge", "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8"),
                ("email", "asdf@stytch.com"),
                ("login_magic_link_url", "https://myapp.com/login"),
                ("login_expiration_minutes", 30),
            ]
        )
    }

    func testMagicLinksAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        let parameters: StytchClient.MagicLinks.AuthenticateParameters = .init(
            token: "12345",
            sessionDuration: 15
        )

        await XCTAssertThrowsErrorAsync(try await StytchClient.magicLinks.authenticate(parameters: parameters))

        try Current.keychainClient.set(String.mockPKCECodeVerifier, for: .emlPKCECodeVerifier)

        XCTAssertNotNil(try Current.keychainClient.get(.emlPKCECodeVerifier))

        Current.timer = { _, _, _ in .init() }

        let response = try await StytchClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.user.id, authResponse.user.id)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        XCTAssertTrue(try Current.keychainClient.get(.emlPKCECodeVerifier).isEmpty)

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/magic_links/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"token\":\"12345\",\"session_duration_minutes\":15,\"code_verifier\":\"e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741\"}".utf8))
    }
}
