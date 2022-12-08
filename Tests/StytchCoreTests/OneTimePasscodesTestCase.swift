import XCTest
@testable import StytchCore

final class OneTimePasscodesTestCase: BaseTestCase {
    func testOtpLoginOrCreate() async throws {
        let container: DataContainer<StytchClient.OneTimePasscodes.OTPResponse> = .init(
            data: .init(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(methodId: "method_id_1234")
            )
        )
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data), .success(data), .success(data))

        try await [
            (
                StytchClient.OneTimePasscodes.Parameters(deliveryMethod: .whatsapp(phoneNumber: "+12345678901"), expiration: 3),
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

        Current.timer = { _, _, _ in .init() }

        let response = try await StytchClient.otps.authenticate(parameters: parameters)
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.requestId, "1234")
        XCTAssertEqual(response.user.id, authResponse.user.id)
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
}
