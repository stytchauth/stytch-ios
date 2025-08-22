import XCTest
@testable import StytchCore

final class TOTPTestCase: BaseTestCase {
    func testCreate() async throws {
        networkInterceptor.responses {
            StytchClient.TOTP.CreateResponse(requestId: "", statusCode: 200, wrapped: .init(totpId: "", secret: "", qrCode: "", recoveryCodes: [], user: .mock(userId: ""), userId: ""))
        }

        _ = try await StytchClient.totps.create(parameters: .init())

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/totps", method: .post(["expiration_minutes": 5]))
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }

        Current.timer = { _, _, _ in Self.mockTimer }

        _ = try await StytchClient.totps.authenticate(parameters: .init(totpCode: "test-code"))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/totps/authenticate", method: .post(["totp_code": "test-code", "session_duration_minutes": 5]))

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.totp)
    }

    func testRecover() async throws {
        networkInterceptor.responses {
            StytchClient.TOTP.RecoverResponse(requestId: "", statusCode: 200, wrapped: .init(userId: "", totpId: "", user: .mock(userId: ""), session: .mock(userId: ""), sessionToken: "", sessionJwt: ""))
        }

        Current.timer = { _, _, _ in Self.mockTimer }

        _ = try await StytchClient.totps.recover(parameters: .init(recoveryCode: "recover-edoc"))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/totps/recover", method: .post(["recovery_code": "recover-edoc", "session_duration_minutes": 5]))
    }

    func testRecoveryCodes() async throws {
        networkInterceptor.responses {
            StytchClient.TOTP.RecoveryCodesResponse(requestId: "", statusCode: 200, wrapped: .init(userId: "", totps: [.init(lhs: .init(totpId: "", verified: false), rhs: .init(recoveryCodes: ["1234", "5678"]))]))
        }

        _ = try await StytchClient.totps.recoveryCodes()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/totps/recovery_codes", method: .post([:]))
    }
}
