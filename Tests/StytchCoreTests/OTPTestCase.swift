import XCTest
@testable import StytchCore

final class OTPTestCase: BaseTestCase {
    private typealias Base = StytchClient.OTP
    private typealias ExpectedValues = ExpectedRequest<Base.Parameters>

    private let response: Base.OTPResponse = .init(
        requestId: "1234",
        statusCode: 200,
        wrapped: .init(methodId: "method_id_1234")
    )

    func testOtpLoginOrCreate() async throws {
        networkInterceptor.responses {
            response
            response
            response
        }

        try await [
            ExpectedValues(
                parameters: .init(deliveryMethod: .whatsapp(phoneNumber: "+12345678901"), expiration: 3),
                urlString: "https://web.stytch.com/sdk/v1/otps/whatsapp/login_or_create",
                body: ["expiration_minutes": 3, "phone_number": "+12345678901"]
            ),
            .init(
                parameters: .init(deliveryMethod: .sms(phoneNumber: "+11098765432")),
                urlString: "https://web.stytch.com/sdk/v1/otps/sms/login_or_create",
                body: ["phone_number": "+11098765432"]
            ),
            .init(
                parameters: .init(deliveryMethod: .email(email: "test@stytch.com")),
                urlString: "https://web.stytch.com/sdk/v1/otps/email/login_or_create",
                body: ["email": "test@stytch.com"]
            ),
        ]
        .enumerated()
        .asyncForEach { index, expected in
            _ = try await StytchClient.otps.loginOrCreate(parameters: expected.parameters)

            try XCTAssertRequest(networkInterceptor.requests[index], urlString: expected.urlString, method: .post(expected.body))

            XCTAssertNil(StytchClient.sessions.sessionJwt)
            XCTAssertNil(StytchClient.sessions.sessionToken)
        }
    }

    func testOtpSendWithNoSession() async throws {
        networkInterceptor.responses {
            response
            response
            response
            response
        }

        XCTAssertFalse(Current.sessionStorage.persistedSessionIdentifiersExist)

        try await [
            ExpectedValues(
                parameters: .init(deliveryMethod: .whatsapp(phoneNumber: "+12345678901"), expiration: 3),
                urlString: "https://web.stytch.com/sdk/v1/otps/whatsapp/send/primary",
                body: ["expiration_minutes": 3, "phone_number": "+12345678901"]
            ),
            .init(
                parameters: .init(deliveryMethod: .sms(phoneNumber: "+11098765432")),
                urlString: "https://web.stytch.com/sdk/v1/otps/sms/send/primary",
                body: ["phone_number": "+11098765432"]
            ),
            .init(
                parameters: .init(deliveryMethod: .email(email: "test@stytch.com", loginTemplateId: "fake-id", signupTemplateId: "blah")),
                urlString: "https://web.stytch.com/sdk/v1/otps/email/send/primary",
                body: ["email": "test@stytch.com", "login_template_id": "fake-id", "signup_template_id": "blah"]
            ),
            .init(
                parameters: .init(deliveryMethod: .email(email: "test@stytch.com")),
                urlString: "https://web.stytch.com/sdk/v1/otps/email/send/primary",
                body: ["email": "test@stytch.com"]
            ),
        ]
        .enumerated()
        .asyncForEach { index, expected in
            _ = try await StytchClient.otps.send(parameters: expected.parameters)

            try XCTAssertRequest(networkInterceptor.requests[index], urlString: expected.urlString, method: .post(expected.body))

            XCTAssertNil(StytchClient.sessions.sessionJwt)
            XCTAssertNil(StytchClient.sessions.sessionToken)
        }
    }

    func testOtpSendWithActiveSession() async throws {
        networkInterceptor.responses {
            response
            response
            response
        }

        try Current.keychainClient.set("123", for: .sessionToken)

        XCTAssertTrue(Current.sessionStorage.persistedSessionIdentifiersExist)

        try await [
            ExpectedValues(
                parameters: .init(deliveryMethod: .whatsapp(phoneNumber: "+12345678901"), expiration: 3),
                urlString: "https://web.stytch.com/sdk/v1/otps/whatsapp/send/secondary",
                body: ["expiration_minutes": 3, "phone_number": "+12345678901"]
            ),
            .init(
                parameters: .init(deliveryMethod: .sms(phoneNumber: "+11098765432")),
                urlString: "https://web.stytch.com/sdk/v1/otps/sms/send/secondary",
                body: ["phone_number": "+11098765432"]
            ),
            .init(
                parameters: .init(deliveryMethod: .email(email: "test@stytch.com")),
                urlString: "https://web.stytch.com/sdk/v1/otps/email/send/secondary",
                body: ["email": "test@stytch.com"]
            ),
        ]
        .enumerated()
        .asyncForEach { index, expected in
            _ = try await StytchClient.otps.send(parameters: expected.parameters)
            try XCTAssertRequest(networkInterceptor.requests[index], urlString: expected.urlString, method: .post(expected.body))
        }
    }

    func testOtpAuthenticate() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }
        let parameters: Base.AuthenticateParameters = .init(
            code: "i_am_code",
            methodId: "method_id_fake_id",
            sessionDuration: 20
        )

        XCTAssertNil(StytchClient.sessions.sessionToken)
        XCTAssertNil(StytchClient.sessions.sessionJwt)

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.otps.authenticate(parameters: parameters)

        XCTAssertEqual(StytchClient.sessions.sessionToken, .opaque("hello_session"))
        XCTAssertEqual(StytchClient.sessions.sessionJwt, .jwt("jwt_for_me"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/otps/authenticate",
            method: .post([
                "token": "i_am_code",
                "method_id": "method_id_fake_id",
                "session_duration_minutes": 20,
            ])
        )
    }
}
