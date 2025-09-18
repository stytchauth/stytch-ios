@preconcurrency import SwiftyJSON
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
            expirationMinutes: 5
        )

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.totp.create(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/totp",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "expiration_minutes": JSON(integerLiteral: 5),
                "organization_id": JSON(stringLiteral: organizationId),
                "member_id": JSON(stringLiteral: memberId),
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
            sessionDurationMinutes: 5,
            organizationId: organizationId,
            memberId: memberId,
            code: code
        )

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await StytchB2BClient.totp.authenticate(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/totp/authenticate",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "session_duration_minutes": JSON(integerLiteral: 5),
                "organization_id": JSON(stringLiteral: organizationId),
                "member_id": JSON(stringLiteral: memberId),
                "code": JSON(stringLiteral: code),
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
