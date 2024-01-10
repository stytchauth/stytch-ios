import XCTest
@testable import StytchCore
@testable import StytchUI

class BaseTestCase: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
}

extension User {
    static func mock(userId: ID) -> Self {
        .init(
            createdAt: Current.date(),
            cryptoWallets: [],
            emails: [],
            userId: userId,
            name: .init(firstName: "first", lastName: "last", middleName: nil),
            password: nil,
            phoneNumbers: [],
            providers: [],
            status: .active,
            totps: [],
            webauthnRegistrations: [],
            biometricRegistrations: [],
            untrustedMetadata: nil,
            trustedMetadata: nil
        )
    }
}

extension Session {
    static func mock(userId: User.ID) -> Self {
        let refDate = Date()

        return .init(
            attributes: .init(ipAddress: "", userAgent: ""),
            authenticationFactors: [
                .init(
                    rawData: [
                        "type": "magic_link",
                        "last_authenticated_at": .string(ISO8601DateFormatter().string(from: refDate.addingTimeInterval(-30))),
                    ],
                    kind: "magic_link",
                    lastAuthenticatedAt: refDate.addingTimeInterval(-30)
                ),
            ],
            expiresAt: refDate.addingTimeInterval(30),
            lastAccessedAt: refDate.addingTimeInterval(-30),
            sessionId: "im_a_session_id",
            startedAt: refDate.addingTimeInterval(-30),
            userId: userId
        )
    }
}

extension AuthenticateResponse {
    static var mock: Self {
        let userId: User.ID = "im_a_user_id"
        return .init(
            requestId: "1234",
            statusCode: 200,
            wrapped: .init(
                user: .mock(userId: userId),
                sessionToken: "hello_session",
                sessionJwt: "jwt_for_me",
                session: .mock(userId: userId)
            )
        )
    }
}

extension BasicResponse {
    static var mock: Self {
        return .init(requestId: "i-am-a-request-id", statusCode: 200)
    }
}

extension StytchClient.Passwords.CreateResponse {
    static var mock: Self {
        let mockUser = User.mock(userId: "im_a_user_id")
        let mockSession = Session.mock(userId: "im_a_user_id")
        return .init(
            requestId: "i-am-a-request-id",
            statusCode: 200,
            wrapped: .init(
                emailId: "test@stytch.com",
                userId: mockUser.id,
                user: mockUser,
                sessionToken: "mock-session-token",
                sessionJwt: "mock-session-jwt",
                session: mockSession
            )
        )
    }
}

extension StytchClient.Passwords.StrengthCheckResponse {
    static var successMock: Self {
        return .init(
            requestId: "i-am-a-request-id",
            statusCode: 200,
            wrapped: .init(validPassword: true, score: 1.0, breachedPassword: false, feedback: nil)
        )
    }
}

extension StytchClient.OTP.OTPResponse {
    static var mock: Self {
        return .init(
            requestId: "i-am-a-request-id",
            statusCode: 200,
            wrapped: .init(methodId: "otp-method-id")
        )
    }
}
