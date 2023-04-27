import XCTest
@testable import StytchCore

final class B2BPasswordsTestCase: BaseTestCase {
    private let client = StytchB2BClient.passwords

    func testAuthenticate() async throws {
        let authParams: StytchB2BClient.Passwords.AuthenticateParameters = .init(
            organizationId: "org123",
            email: "user@stytch.com",
            password: "password123",
            sessionDuration: 26
        )
        networkInterceptor.responses { B2BAuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }
        _ = try await client.authenticate(parameters: authParams)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/passwords/authenticate",
            method: .post([
                "email_address": "user@stytch.com",
                "session_duration_minutes": 26,
                "password": "password123",
                "organization_id": "org123",
            ])
        )
    }

    func testStrengthCheck() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Passwords.StrengthCheckResponse(requestId: "123", statusCode: 200, wrapped: .init(validPassword: false, score: 20, breachedPassword: true, strengthPolicy: "something", breachDetectionOnCreate: true, zxcvbnFeedback: .init(suggestions: [], warning: "meh. do something."), ludsFeedback: nil))
        }
        _ = try await client.strengthCheck(parameters: .init(email: "bob@loblaw.com", password: "p@ssword123"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/passwords/strength_check",
            method: .post([
                "password": "p@ssword123",
                "email_address": "bob@loblaw.com",
            ])
        )
    }

    func testResetByEmail() async throws {
        await XCTAssertThrowsErrorAsync(_ = try await client.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR")))

        networkInterceptor.responses {
            BasicResponse(requestId: "123", statusCode: 200)
            B2BAuthenticateResponse.mock
        }
        _ = try await client.resetByEmailStart(
            parameters: .init(organizationId: "org123", email: "user@stytch.com", loginUrl: nil, resetPasswordUrl: XCTUnwrap(URL(string: "https://stytch.com/reset")), resetPasswordExpiration: 15, resetPasswordTemplateId: "one-two-buckle-my-shoe")
        )

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/passwords/email/reset/start",
            method: .post([
                "organization_id": "org123",
                "email_address": "user@stytch.com",
                "reset_password_expiration_minutes": 15,
                "reset_password_redirect_url": "https://stytch.com/reset",
                "code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "code_challenge_method": "S256",
                "reset_password_template_id": "one-two-buckle-my-shoe",
            ])
        )

        Current.timer = { _, _, _ in .init() }

        _ = try await client.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR"))

        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://web.stytch.com/sdk/v1/b2b/passwords/email/reset",
            method: .post([
                "password_reset_token": "12345",
                "code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "session_duration_minutes": 30,
                "password": "iAMpasswordHEARmeROAR",
            ])
        )
    }

    func testResetByExistingPassword() async throws {
        networkInterceptor.responses { B2BAuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }

        _ = try await client.resetByExistingPassword(parameters: .init(organizationId: "org123", email: "jobe@bluth.com", existingPassword: "magicIsFun", newPassword: "buster_is_trouble"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/passwords/existing_password/reset",
            method: .post([
                "organization_id": "org123",
                "email_address": "jobe@bluth.com",
                "existing_password": "magicIsFun",
                "new_password": "buster_is_trouble",
                "session_duration_minutes": 30,
            ])
        )
    }

    func testResetBySession() async throws {
        networkInterceptor.responses { StytchB2BClient.Passwords.ResetBySessionResponse(requestId: "", statusCode: 200, wrapped: .init(memberSession: .mock, member: .mock, organization: .mock)) }
        Current.timer = { _, _, _ in .init() }

        _ = try await client.resetBySession(parameters: .init(organizationId: "org123", password: "hi, i'm Tom."))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/passwords/session/reset",
            method: .post([
                "organization_id": "org123",
                "password": "hi, i'm Tom.",
            ])
        )
    }
}
