import Combine
import XCTest
@testable import StytchCore

// swiftlint:disable multiline_function_chains

final class UserManagementTestCase: BaseTestCase {
    var subscriptions: Set<AnyCancellable> = []

    func testSync() throws {
        XCTAssertNil(StytchClient.user.getSync())
        Current.userStorage.update(.mock(userId: "123"))
        XCTAssertNotNil(StytchClient.user.getSync())
    }

    func testGet() async throws {
        networkInterceptor.responses {
            StytchClient.UserManagement.UserResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .mock(userId: "mock-user-id-123")
            )
        }
        XCTAssertNil(StytchClient.user.getSync())
        let getUserResponse = try await StytchClient.user.get()
        XCTAssertNotNil(StytchClient.user.getSync())
        XCTAssertEqual(getUserResponse.id, StytchClient.user.getSync()?.id)
        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://api.stytch.com/sdk/v1/users/me", method: .get)
    }

    func testUpdate() async throws {
        networkInterceptor.responses {
            StytchClient.UserManagement.NestedUserResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchClient.UserManagement.UserResponseData(
                    user: .mock(userId: "mock-user-id-123")
                )
            )
        }
        XCTAssertNil(StytchClient.user.getSync())
        let updateUserResponse = try await StytchClient.user.update(parameters: .init(name: .init(firstName: "Dan"), untrustedMetadata: ["blah": 1]))
        XCTAssertNotNil(StytchClient.user.getSync())
        XCTAssertEqual(updateUserResponse.user.id, StytchClient.user.getSync()?.id)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/users/me",
            method: .put(["name": ["first_name": "Dan"], "untrusted_metadata": ["blah": 1]])
        )
    }

    func testSearchUserByEmail() async throws {
        let email = "someone@example.com"
        networkInterceptor.responses {
            StytchClient.UserManagement.UserSearchResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(userType: StytchClient.UserManagement.UserType.new)
            )
        }

        _ = try await StytchClient.user.searchUser(email: email)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/users/search",
            method: .post(["email": email])
        )
    }

    func testDeleteFactor() async throws {
        let response: StytchClient.UserManagement.UserResponseData = .init(user: .mock(userId: "mock-user-id-123"))
        networkInterceptor.responses {
            response
            response
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
            (.totp(id: .init(rawValue: "totp_123983")), "totps", "totp_123983"),
            (.oauth(id: .init(rawValue: "oauth_123983")), "oauth", "oauth_123983"),
        ]

        try await factors.enumerated().asyncForEach { index, values in
            Current.userStorage.update(nil)
            XCTAssertNil(StytchClient.user.getSync())
            _ = try await StytchClient.user.deleteFactor(values.factor)
            XCTAssertNotNil(StytchClient.user.getSync())
            try XCTAssertRequest(networkInterceptor.requests[index], urlString: "https://api.stytch.com/sdk/v1/users/\(values.pathComponent)/\(values.id)", method: .delete)
        }
    }

    func testUserPublisherAvailable() throws {
        let expectation = XCTestExpectation(description: "onUserChange completes")
        var receivedUser: User?
        var receivedDate: Date?

        StytchClient.user.onUserChange.sink { userInfo in
            switch userInfo {
            case let .available(user, lastValidatedAtDate):
                receivedUser = user
                receivedDate = lastValidatedAtDate
                expectation.fulfill()
            case .unavailable:
                break
            }
        }.store(in: &subscriptions)

        Current.userStorage.update(.mock(userId: "123"))

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedUser)
        XCTAssertNotNil(receivedDate)
    }

    func testUserPublisherUnavailable() throws {
        let expectation = XCTestExpectation(description: "onUserChange completes")

        StytchClient.user.onUserChange.sink { userInfo in
            switch userInfo {
            case .available:
                break
            case .unavailable:
                expectation.fulfill()
            }
        }.store(in: &subscriptions)

        Current.userStorage.update(nil)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(StytchClient.user.getSync())
    }
}
