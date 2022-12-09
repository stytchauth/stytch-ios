@testable import StytchCore
import XCTest

final class UserManagementTestCase: BaseTestCase {
    func testSync() throws {
        XCTAssertNil(StytchClient.user.syncUser)
        Current.localStorage.user = .mock(userId: "123")
        XCTAssertNotNil(StytchClient.user.syncUser)
    }

    func testGet() async throws {
        let userResponse: UserResponse = .init(requestId: "123", statusCode: 200, wrapped: .mock(userId: "mock-user-id-123"))
        let container: DataContainer<UserResponse> = .init(data: userResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))

        XCTAssertNil(StytchClient.user.syncUser)
        let getUserResponse = try await StytchClient.user.get()
        XCTAssertNotNil(StytchClient.user.syncUser)
        XCTAssertEqual(getUserResponse.id, StytchClient.user.syncUser?.id)
        try XCTAssertRequest(request, urlString: "https://web.stytch.com/sdk/v1/users/me", method: .get)
    }

    func testDeleteFactor() async throws {
        let userResponse: UserResponse = .init(requestId: "123", statusCode: 200, wrapped: .mock(userId: "mock-user-id-123"))
        let container: DataContainer<UserResponse> = .init(data: userResponse)
        let data = try Current.jsonEncoder.encode(container)
        var request: URLRequest?
        Current.networkingClient = .mock(
            verifyingRequest: { request = $0 },
            returning: .success(data), .success(data), .success(data), .success(data), .success(data)
        )

        let factors: [(factor: StytchClient.UserManagement.AuthenticationFactor, pathComponent: String, id: String)] = [
            (.email(id: .init(rawValue: "email_123983")), "emails", "email_123983"),
            (.cryptoWallet(id: .init(rawValue: "crypto_123983")), "crypto_wallets", "crypto_123983"),
            (.biometricRegistration(id: .init(rawValue: "bio_123983")), "biometric_registrations", "bio_123983"),
            (.phoneNumber(id: .init(rawValue: "phone_123983")), "phone_numbers", "phone_123983"),
            (.webAuthnRegistration(id: .init(rawValue: "web_123983")), "webauthn_registrations", "web_123983"),
        ]

        try await factors.asyncForEach { factor, pathComponent, id in
            Current.localStorage = .init()
            XCTAssertNil(StytchClient.user.syncUser)
            _ = try await StytchClient.user.deleteFactor(factor)
            XCTAssertNotNil(StytchClient.user.syncUser)
            try XCTAssertRequest(request, urlString: "https://web.stytch.com/sdk/v1/users/\(pathComponent)/\(id)", method: .delete)
        }
    }
}
