import XCTest
@testable import StytchCore

final class UserManagementTestCase: BaseTestCase {
    func testSync() throws {
        XCTAssertNil(StytchClient.user.getSync())
        Current.localStorage.user = .mock(userId: "123")
        XCTAssertNotNil(StytchClient.user.getSync())
    }

    func testGet() async throws {
        networkInterceptor.responses { UserResponse(requestId: "123", statusCode: 200, wrapped: .mock(userId: "mock-user-id-123")) }
        XCTAssertNil(StytchClient.user.getSync())
        let getUserResponse = try await StytchClient.user.get()
        XCTAssertNotNil(StytchClient.user.getSync())
        XCTAssertEqual(getUserResponse.id, StytchClient.user.getSync()?.id)
        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/users/me", method: .get)
    }

    func testDeleteFactor() async throws {
        let response: UserResponse = .init(requestId: "123", statusCode: 200, wrapped: .mock(userId: "mock-user-id-123"))
        networkInterceptor.responses {
            response
            response
            response
            response
            response
        }

        let factors: [(factor: StytchClient.UserManagement.AuthenticationFactor, pathComponent: String, id: String)] = [
            (.email(id: .init(rawValue: "email_123983")), "emails", "email_123983"),
            (.cryptoWallet(id: .init(rawValue: "crypto_123983")), "crypto_wallets", "crypto_123983"),
            (.biometricRegistration(id: .init(rawValue: "bio_123983")), "biometric_registrations", "bio_123983"),
            (.phoneNumber(id: .init(rawValue: "phone_123983")), "phone_numbers", "phone_123983"),
            (.webAuthnRegistration(id: .init(rawValue: "web_123983")), "webauthn_registrations", "web_123983"),
        ]

        try await factors.enumerated().asyncForEach { index, values in
            Current.localStorage.user = nil
            XCTAssertNil(StytchClient.user.getSync())
            _ = try await StytchClient.user.deleteFactor(values.factor)
            XCTAssertNotNil(StytchClient.user.getSync())
            try XCTAssertRequest(networkInterceptor.requests[index], urlString: "https://web.stytch.com/sdk/v1/users/\(values.pathComponent)/\(values.id)", method: .delete)
        }
    }
}
