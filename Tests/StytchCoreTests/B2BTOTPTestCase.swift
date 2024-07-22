import XCTest
@testable import StytchCore

final class B2BTOTPTestCase: BaseTestCase {
    func testCreate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.TOTP.CreateResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let organizationId = "orgid1234"
        let memberId = "memberid1234"

        let parameters = StytchB2BClient.TOTP.CreateParameters(
            organizationId: organizationId,
            memberId: memberId,
            expirationMinutes: .defaultSessionDuration
        )

        Current.sessionStorage.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.totp.create(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/totp",
            method: .post([
                "intermediate_session_token": JSON.string(intermediateSessionToken),
                "expiration_minutes": JSON.number(30),
                "organization_id": JSON.string(organizationId),
                "member_id": JSON.string(memberId),
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

        let parameters = StytchB2BClient.TOTP.AuthenticateParameters(
            sessionDurationMinutes: .defaultSessionDuration,
            organizationId: organizationId,
            memberId: memberId,
            code: code
        )

        Current.sessionStorage.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.totp.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/totp/authenticate",
            method: .post([
                "intermediate_session_token": JSON.string(intermediateSessionToken),
                "session_duration_minutes": JSON.number(30),
                "organization_id": JSON.string(organizationId),
                "member_id": JSON.string(memberId),
                "code": JSON.string(code),
            ])
        )
    }
}

extension StytchB2BClient.TOTP.CreateResponseData {
    static var mock: Self {
        .init(
            totpRegistrationId: "",
            secret: "",
            qrCode: "",
            recoveryCodes: []
        )
    }
}
