import XCTest
@testable import StytchCore

@available(iOS 13.0, *)
final class AsyncMethodsTestCase: BaseTestCase {
    func testMagicLinksEmailLoginOrCreate() async throws {
        let container = DataContainer(data: BasicResponse(requestId: "1234", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        let baseUrl = try XCTUnwrap(URL(string: "https://myapp.com"))
        let parameters: StytchClient.MagicLinks.Email.Parameters = .init(
            email: "asdf@stytch.com",
            loginMagicLinkUrl: baseUrl.appendingPathComponent("login"),
            loginExpiration: 30,
            signupMagicLinkUrl: baseUrl.appendingPathComponent("signup"),
            signupExpiration: 30
        )

        let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/magic_links/email/login_or_create")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"email\":\"asdf@stytch.com\",\"signup_magic_link_url\":\"https:\\/\\/myapp.com\\/signup\",\"login_magic_link_url\":\"https:\\/\\/myapp.com\\/login\",\"login_expiration_minutes\":30,\"signup_expiration_minutes\":30}".utf8))
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

        let response = try await StytchClient.magicLinks.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, authResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/magic_links/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"token\":\"12345\",\"session_duration_minutes\":15}".utf8))
    }

    func testSessionsAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))

        let parameters: StytchClient.Sessions.AuthenticateParameters = .init(sessionDuration: 15)

        let unauthenticatedResult = try await StytchClient.sessions.authenticate(parameters: parameters)

        guard case .unauthenticated = unauthenticatedResult else {
            XCTFail("Expected to be unauthenticated")
            return
        }

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        let authenticatedResult = try await StytchClient.sessions.authenticate(parameters: parameters)

        guard case let .authenticated(response) = authenticatedResult else {
            XCTFail("Expected authenticated")
            return
        }
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, authResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/sessions/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"session_duration_minutes\":15,\"session_token\":\"opaque_all_day\"}".utf8))

        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))
        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
    }

    func testSessionsRevoke() async throws {
        let container: DataContainer<BasicResponse> = .init(data: .init(requestId: "request_id", statusCode: 200))
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))

        let unauthenticatedResult = try await StytchClient.sessions.revoke()

        guard case .unauthenticated = unauthenticatedResult else {
            XCTFail("Expected to be unauthenticated")
            return
        }

        Current.sessionStorage.updateSession(
            .mock(userId: "i_am_user"),
            tokens: [.jwt("i'm_jwt"), .opaque("opaque_all_day")],
            hostUrl: try XCTUnwrap(URL(string: "https://url.com"))
        )

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("opaque_all_day"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("i'm_jwt"))

        let authenticatedResult = try await StytchClient.sessions.revoke()

        guard case let .authenticated(response) = authenticatedResult else {
            XCTFail("Expected authenticated")
            return
        }
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "request_id")

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/sessions/revoke")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"session_token\":\"opaque_all_day\"}".utf8))

        XCTAssertNil(StytchClient.sessions.sessionJwt)
        XCTAssertNil(StytchClient.sessions.sessionToken)
    }

    @available(iOS 13.0, *)
    func testOtpLoginOrCreate() async throws {
        let container: DataContainer<StytchClient.OneTimePasscodes.LoginOrCreateResponse> = .init(
            data: .init(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(methodId: "method_id_1234")
            )
        )
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))

        try await [
            (
                StytchClient.OneTimePasscodes.LoginOrCreateParameters(deliveryMethod: .whatsapp(phoneNumber: "+12345678901"), expiration: 3),
                "https://web.stytch.com/sdk/v1/otps/whatsapp/login_or_create",
                "{\"expiration_minutes\":3,\"phone_number\":\"+12345678901\"}"
            ),
            (
                .init(deliveryMethod: .sms(phoneNumber: "+11098765432")),
                "https://web.stytch.com/sdk/v1/otps/sms/login_or_create",
                "{\"phone_number\":\"+11098765432\"}"
            ),
            (
                .init(deliveryMethod: .email("test@stytch.com")),
                "https://web.stytch.com/sdk/v1/otps/email/login_or_create",
                "{\"email\":\"test@stytch.com\"}"
            ),
        ]
        .asyncForEach { params, urlString, body in
            let response = try await StytchClient.otps.loginOrCreate(parameters: params)
            XCTAssertEqual(response.methodId, "method_id_1234")
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.requestId, "1234")

            // Verify request
            guard let request = request else { XCTFail("Request should be present"); return }

            XCTAssertEqual(request.url?.absoluteString, urlString)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBody, Data(body.utf8))

            XCTAssertNil(StytchClient.sessions.sessionJwt)
            XCTAssertNil(StytchClient.sessions.sessionToken)
        }
    }

    func testOtpAuthenticate() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        let parameters: StytchClient.OneTimePasscodes.AuthenticateParameters = .init(
            code: "i_am_code",
            methodId: "method_id_fake_id",
            sessionDuration: 20
        )

        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        let response = try await StytchClient.otps.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.userId, authResponse.userId)
        XCTAssertEqual(response.sessionToken, "hello_session")
        XCTAssertEqual(response.sessionJwt, "jwt_for_me")
        XCTAssertTrue(Calendar.current.isDate(response.session.expiresAt, equalTo: authResponse.session.expiresAt, toGranularity: .nanosecond))

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))

        // Verify request
        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/otps/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"token\":\"i_am_code\",\"method_id\":\"method_id_fake_id\",\"session_duration_minutes\":20}".utf8))
    }

    func testHandleUrl() async throws {
        let authResponse: AuthenticateResponse = .mock
        let container: DataContainer<AuthenticateResponse> = .init(data: authResponse)
        let data = try Current.jsonEncoder.encode(container)
        Current.networkingClient = .mock(returning: .success(data))

        let notHandledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345"))

        switch try await StytchClient.handle(url: notHandledUrl, sessionDuration: 30) {
        case .handled:
            XCTFail("expected to be nothandled")
        case .notHandled:
            break
        }

        let handledUrl = try XCTUnwrap(URL(string: "https://myapp.com?token=12345&stytch_token_type=magic_links"))

        switch try await StytchClient.handle(url: handledUrl, sessionDuration: 30) {
        case let .handled(response):
            XCTAssertEqual(response.sessionJwt, "jwt_for_me")
            XCTAssertEqual(response.session.authenticationFactors.count, 1)
        case .notHandled:
            XCTFail("expected to be handled")
        }
    }

    func testExternalSessionsUpdate() {
        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        StytchClient.sessions.update(sessionTokens: [.opaque("token"), .jwt("jwt")])

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("token"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt"))
    }
}
