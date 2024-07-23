import XCTest
@testable import StytchCore

final class B2BOTPTestCase: BaseTestCase {
    func testSend() async throws {
        networkInterceptor.responses {
            BasicResponse(requestId: "1234", statusCode: 200)
            BasicResponse(requestId: "1234", statusCode: 200)
        }

        let organizationId = "orgid1234"
        let memberId = "memberid1234"
        let mfaPhoneNumber = "+15555555555"
        let locale = "en_us"

        let parameters = StytchB2BClient.OTP.SendParameters(
            organizationId: organizationId,
            memberId: memberId,
            mfaPhoneNumber: mfaPhoneNumber,
            locale: locale
        )

        Current.sessionStorage.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.otp.send(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/otps/sms/send",
            method: .post([
                "intermediate_session_token": JSON.string(intermediateSessionToken),
                "organization_id": JSON.string(organizationId),
                "member_id": JSON.string(memberId),
                "mfa_phone_number": JSON.string(mfaPhoneNumber),
                "locale": JSON.string(locale),
                "enable_autofill": false
            ])
        )
        
        // Now test with autofill enabled
        let autofillParameters = StytchB2BClient.OTP.SendParameters(
            organizationId: organizationId,
            memberId: memberId,
            mfaPhoneNumber: mfaPhoneNumber,
            locale: locale,
            enableAutofill: true
        )
        _ = try await StytchB2BClient.otp.send(parameters: autofillParameters)

        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://web.stytch.com/sdk/v1/b2b/otps/sms/send",
            method: .post([
                "intermediate_session_token": JSON.string(intermediateSessionToken),
                "organization_id": JSON.string(organizationId),
                "member_id": JSON.string(memberId),
                "mfa_phone_number": JSON.string(mfaPhoneNumber),
                "locale": JSON.string(locale),
                "enable_autofill": true
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

        let parameters = StytchB2BClient.OTP.AuthenticateParameters(
            sessionDurationMinutes: .defaultSessionDuration,
            organizationId: organizationId,
            memberId: memberId,
            code: code
        )

        Current.sessionStorage.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.otp.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/otps/sms/authenticate",
            method: .post([
                "intermediate_session_token": JSON.string(intermediateSessionToken),
                "session_duration_minutes": JSON.number(5),
                "organization_id": JSON.string(organizationId),
                "member_id": JSON.string(memberId),
                "code": JSON.string(code),
            ])
        )
    }
}
