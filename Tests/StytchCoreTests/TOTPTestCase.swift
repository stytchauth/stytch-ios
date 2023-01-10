import XCTest
@testable import StytchCore

final class TOTPTestCase: BaseTestCase {
    func testCreate() async throws {
        try networkInterceptor.appendSuccess(StytchClient.TOTP.CreateResponse(requestId: "", statusCode: 200, wrapped: .init(totpId: "", secret: "", qrCode: "", recoveryCodes: [], user: .mock(userId: ""), userId: "")))

        _ = try await StytchClient.totp.create(parameters: .init())

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps", method: .post(["expiration_minutes": 30]))
    }

    func testAuthenticate() async throws {
        try networkInterceptor.appendSuccess(AuthenticateResponse.mock)

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.totp.authenticate(parameters: .init(totpCode: "test-code"))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps/authenticate", method: .post(["totp_code": "test-code", "session_duration_minutes": 30]))
    }

    func testRecover() async throws {
        try networkInterceptor.appendSuccess(StytchClient.TOTP.RecoverResponse(requestId: "", statusCode: 200, wrapped: .init(userId: "", totpId: "", user: .mock(userId: ""), session: .mock(userId: ""), sessionToken: "", sessionJwt: "")))

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.totp.recover(parameters: .init(recoveryCode: "recover-edoc"))

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps/recover", method: .post(["recovery_code": "recover-edoc", "session_duration_minutes": 30]))
    }

    func testRecoveryCodes() async throws {
        try networkInterceptor.appendSuccess(StytchClient.TOTP.RecoveryCodesResponse(requestId: "", statusCode: 200, wrapped: .init(userId: "", totps: [.init(lhs: .init(totpId: "", verified: false), rhs: .init(recoveryCodes: ["1234", "5678"]))])))

        _ = try await StytchClient.totp.recoveryCodes()

        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/totps/recovery_codes", method: .post([:]))
    }
}
