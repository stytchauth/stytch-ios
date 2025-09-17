@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

final class B2BOTPTestCase: BaseTestCase {
    func testSend() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }

        let organizationId = "orgid1234"
        let memberId = "memberid1234"
        let mfaPhoneNumber = "+15555555555"
        let locale = StytchLocale.en

        let parameters = StytchB2BClient.OTP.SMS.SendParameters(
            organizationId: organizationId,
            memberId: memberId,
            mfaPhoneNumber: mfaPhoneNumber,
            locale: locale
        )

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.otp.sms.send(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/sms/send",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "organization_id": JSON(stringLiteral: organizationId),
                "member_id": JSON(stringLiteral: memberId),
                "mfa_phone_number": JSON(stringLiteral: mfaPhoneNumber),
                "locale": JSON(stringLiteral: locale.rawValue),
                "enable_autofill": false,
            ])
        )
    }

    func testSendWithAutofill() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }

        let organizationId = "orgid1234"
        let memberId = "memberid1234"
        let mfaPhoneNumber = "+15555555555"
        let locale = StytchLocale.en

        let parameters = StytchB2BClient.OTP.SMS.SendParameters(
            organizationId: organizationId,
            memberId: memberId,
            mfaPhoneNumber: mfaPhoneNumber,
            locale: locale,
            enableAutofill: true
        )

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.otp.sms.send(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/sms/send",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "organization_id": JSON(stringLiteral: organizationId),
                "member_id": JSON(stringLiteral: memberId),
                "mfa_phone_number": JSON(stringLiteral: mfaPhoneNumber),
                "locale": JSON(stringLiteral: locale.rawValue),
                "enable_autofill": true,
            ])
        )
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses {
            B2BAuthenticateResponse.mock
        }

        Current.timer = { _, _, _ in .init() }

        let organizationId = "orgid1234"
        let memberId = "memberid1234"
        let code = "code1234"

        let parameters = StytchB2BClient.OTP.SMS.AuthenticateParameters(
            sessionDurationMinutes: 5,
            organizationId: organizationId,
            memberId: memberId,
            code: code
        )

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.otp.sms.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/sms/authenticate",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "session_duration_minutes": JSON(integerLiteral: 5),
                "organization_id": JSON(stringLiteral: organizationId),
                "member_id": JSON(stringLiteral: memberId),
                "code": JSON(stringLiteral: code),
            ])
        )
    }

    func testEmailLoginOrSignup() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }

        let organizationId = "orgid1234"
        let emailAddress = "test@example.com"
        let loginTemplateId = "login-template-123"
        let signupTemplateId = "signup-template-123"
        let locale = StytchLocale.en

        let parameters = StytchB2BClient.OTP.Email.LoginOrSignupParameters(
            organizationId: organizationId,
            emailAddress: emailAddress,
            loginTemplateId: loginTemplateId,
            signupTemplateId: signupTemplateId,
            locale: locale
        )

        _ = try await StytchB2BClient.otp.email.loginOrSignup(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/email/login_or_signup",
            method: .post([
                "organization_id": JSON(stringLiteral: organizationId),
                "email_address": JSON(stringLiteral: emailAddress),
                "login_template_id": JSON(stringLiteral: loginTemplateId),
                "signup_template_id": JSON(stringLiteral: signupTemplateId),
                "locale": JSON(stringLiteral: locale.rawValue),
            ])
        )
    }

    func testEmailAuthenticate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.OTP.Email.AuthenticateResponse.mock
        }

        Current.timer = { _, _, _ in .init() }

        let code = "code1234"
        let organizationId = "orgid1234"
        let emailAddress = "test@example.com"
        let locale = StytchLocale.en

        let parameters = StytchB2BClient.OTP.Email.AuthenticateParameters(
            code: code,
            organizationId: organizationId,
            emailAddress: emailAddress,
            locale: locale,
            sessionDurationMinutes: 5
        )

        _ = try await StytchB2BClient.otp.email.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/email/authenticate",
            method: .post([
                "code": JSON(stringLiteral: code),
                "organization_id": JSON(stringLiteral: organizationId),
                "email_address": JSON(stringLiteral: emailAddress),
                "locale": JSON(stringLiteral: locale.rawValue),
                "session_duration_minutes": JSON(integerLiteral: 5),
            ])
        )

        XCTAssertEqual(StytchB2BClient.lastAuthMethodUsed, StytchB2BClient.B2BAuthMethod.emailOtp)
    }

    func testDiscoverySend() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
        }

        let emailAddress = "test@example.com"
        let loginTemplateId = "template123"
        let locale = StytchLocale.en

        let parameters = StytchB2BClient.OTP.Email.Discovery.SendParameters(
            emailAddress: emailAddress,
            loginTemplateId: loginTemplateId,
            locale: locale
        )

        _ = try await StytchB2BClient.otp.email.discovery.send(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/email/discovery/send",
            method: .post([
                "email_address": JSON(stringLiteral: emailAddress),
                "login_template_id": JSON(stringLiteral: loginTemplateId),
                "locale": JSON(stringLiteral: locale.rawValue),
            ])
        )
    }

    func testDiscoveryAuthenticate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.DiscoveryAuthenticateResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let emailAddress = "test@example.com"
        let code = "code1234"

        let parameters = StytchB2BClient.OTP.Email.Discovery.AuthenticateParameters(
            code: code,
            emailAddress: emailAddress
        )

        _ = try await StytchB2BClient.otp.email.discovery.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/otps/email/discovery/authenticate",
            method: .post([
                "email_address": JSON(stringLiteral: emailAddress),
                "code": JSON(stringLiteral: code),
            ])
        )
    }
}

extension StytchB2BClient.OTP.Email.AuthenticateResponse {
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
            mfaRequired: nil,
            primaryRequired: nil,
            memberDevice: nil,
            methodId: ""
        )
    )
}
