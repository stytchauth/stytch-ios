@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

final class B2BRecoveryCodesTestCase: BaseTestCase {
    func testGet() async throws {
        networkInterceptor.responses {
            StytchB2BClient.RecoveryCodes.RecoveryCodesResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .mock
            )
        }

        _ = try await StytchB2BClient.recoveryCodes.get()
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/recovery_codes",
            method: .get
        )
    }

    func testRotate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.RecoveryCodes.RecoveryCodesResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .mock
            )
        }

        _ = try await StytchB2BClient.recoveryCodes.rotate()
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/recovery_codes/rotate",
            method: .post(nil)
        )
    }

    func testRecover() async throws {
        networkInterceptor.responses {
            StytchB2BClient.RecoveryCodes.RecoveryCodesRecoverResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let organizationId = "orgid1234"
        let memberId = "memberid1234"
        let recoveryCode = "recoveryCode1234"

        let parameters = StytchB2BClient.RecoveryCodes.RecoveryCodesRecoverParameters(
            sessionDurationMinutes: .defaultSessionDuration,
            organizationId: organizationId,
            memberId: memberId,
            recoveryCode: recoveryCode
        )

        _ = try await StytchB2BClient.recoveryCodes.recover(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/recovery_codes/recover",
            method: .post([
                "session_duration_minutes": JSON(integerLiteral: 5),
                "organization_id": JSON(stringLiteral: organizationId),
                "member_id": JSON(stringLiteral: memberId),
                "recovery_code": JSON(stringLiteral: recoveryCode),
            ])
        )
    }
}

extension StytchB2BClient.RecoveryCodes.RecoveryCodesResponseData {
    static var mock: Self {
        .init(recoveryCodes: [])
    }
}

extension StytchB2BClient.RecoveryCodes.RecoveryCodesRecoverResponseData {
    static var mock: Self {
        .init(recoveryCodesRemaining: 99)
    }
}
