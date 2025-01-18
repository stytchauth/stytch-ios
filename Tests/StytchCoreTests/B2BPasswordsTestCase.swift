@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

// swiftlint:disable function_body_length

final class B2BPasswordsTestCase: BaseTestCase {
    private let client = StytchB2BClient.passwords

    func testAuthenticate() async throws {
        let authParams: StytchB2BClient.Passwords.AuthenticateParameters = .init(
            organizationId: "org123",
            emailAddress: "user@stytch.com",
            password: "password123",
            sessionDuration: 26,
            locale: .en
        )
        networkInterceptor.responses { B2BMFAAuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await client.authenticate(parameters: authParams)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/authenticate",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "email_address": "user@stytch.com",
                "session_duration_minutes": 26,
                "password": "password123",
                "organization_id": "org123",
                "locale": "en",
            ])
        )
    }

    func testStrengthCheck() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Passwords.StrengthCheckResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    validPassword: false,
                    score: 20,
                    breachedPassword: true,
                    strengthPolicy: .zxcvbn,
                    breachDetectionOnCreate: true,
                    zxcvbnFeedback: .init(suggestions: [], warning: "meh. do something."),
                    ludsFeedback: nil
                )
            )
        }
        _ = try await client.strengthCheck(
            parameters: .init(
                emailAddress: "bob@loblaw.com",
                password: "p@ssword123"
            )
        )

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/strength_check",
            method: .post([
                "password": "p@ssword123",
                "email_address": "bob@loblaw.com",
            ])
        )
    }

    func testResetByEmail() async throws {
        await XCTAssertThrowsErrorAsync(
            try await client.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR")),
            StytchSDKError.missingPKCE
        )

        networkInterceptor.responses {
            BasicResponse(requestId: "123", statusCode: 200)
            B2BMFAAuthenticateResponse.mock
        }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await client.resetByEmailStart(
            parameters: .init(
                organizationId: "org123",
                emailAddress: "user@stytch.com",
                loginUrl: nil,
                resetPasswordUrl: XCTUnwrap(URL(string: "https://stytch.com/reset")),
                resetPasswordExpiration: 15,
                resetPasswordTemplateId: "one-two-buckle-my-shoe",
                locale: .en
            )
        )

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/email/reset/start",
            method: .post([
                "organization_id": "org123",
                "email_address": "user@stytch.com",
                "reset_password_expiration_minutes": 15,
                "reset_password_redirect_url": "https://stytch.com/reset",
                "code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "reset_password_template_id": "one-two-buckle-my-shoe",
                "locale": "en",
            ])
        )

        Current.timer = { _, _, _ in .init() }
        XCTAssertNotNil(Current.pkcePairManager.getPKCECodePair())

        _ = try await client.resetByEmail(
            parameters: .init(
                token: "12345",
                password: "iAMpasswordHEARmeROAR",
                locale: .en
            )
        )

        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/email/reset",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "password_reset_token": "12345",
                "code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "session_duration_minutes": 5,
                "password": "iAMpasswordHEARmeROAR",
                "locale": "en",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())
    }

    func testResetByExistingPassword() async throws {
        networkInterceptor.responses { B2BMFAAuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try await client.resetByExistingPassword(
            parameters: .init(
                organizationId: "org123",
                emailAddress: "jobe@bluth.com",
                existingPassword: "magicIsFun",
                newPassword: "buster_is_trouble",
                locale: .en
            )
        )

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/existing_password/reset",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "organization_id": "org123",
                "email_address": "jobe@bluth.com",
                "existing_password": "magicIsFun",
                "new_password": "buster_is_trouble",
                "session_duration_minutes": 5,
                "locale": "en",
            ])
        )
    }

    func testResetBySession() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Passwords.ResetBySessionResponse(
                requestId: "",
                statusCode: 200,
                wrapped: .init(memberSession: .mock, member: .mock, organization: .mock)
            )
        }
        Current.timer = { _, _, _ in .init() }

        _ = try await client.resetBySession(parameters: .init(organizationId: "org123", password: "hi, i'm Tom.", locale: .en))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/session/reset",
            method: .post([
                "organization_id": "org123",
                "password": "hi, i'm Tom.",
                "locale": "en",
            ])
        )
    }

    func testDiscoveryResetByEmail() async throws {
        // Assert error is thrown when PKCE is missing
        await XCTAssertThrowsErrorAsync(
            try await client.discovery.resetByEmail(parameters: .init(passwordResetToken: "12345", password: "newPassword123")),
            StytchSDKError.missingPKCE
        )

        // Mock responses for resetByEmailStart and resetByEmail
        networkInterceptor.responses {
            BasicResponse(requestId: "123", statusCode: 200)
            StytchB2BClient.DiscoveryAuthenticateResponseData.mock
        }

        // Call resetByEmailStart
        _ = try await client.discovery.resetByEmailStart(
            parameters: .init(
                emailAddress: "user@example.com",
                discoveryRedirectUrl: XCTUnwrap(URL(string: "https://example.com/discovery-redirect")),
                resetPasswordRedirectUrl: XCTUnwrap(URL(string: "https://example.com/reset-password")),
                resetPasswordExpirationMinutes: 15,
                resetPasswordTemplateId: "template123"
            )
        )

        // Verify request for resetByEmailStart
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/discovery/reset/start",
            method: .post([
                "email_address": "user@example.com",
                "discovery_redirect_url": "https://example.com/discovery-redirect",
                "reset_password_redirect_url": "https://example.com/reset-password",
                "reset_password_expiration_minutes": 15,
                "reset_password_template_id": "template123",
                "pkce_code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
            ])
        )

        Current.timer = { _, _, _ in .init() }
        XCTAssertNotNil(Current.pkcePairManager.getPKCECodePair())

        // Call resetByEmail
        _ = try await client.discovery.resetByEmail(
            parameters: .init(passwordResetToken: "12345", password: "newPassword123")
        )

        // Verify request for resetByEmail
        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/discovery/reset",
            method: .post([
                "password_reset_token": "12345",
                "code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "password": "newPassword123",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())
    }

    func testDiscoveryAuthenticate() async throws {
        let authParams = StytchB2BClient.Passwords.Discovery.AuthenticateParameters(
            emailAddress: "user@example.com",
            password: "password123"
        )

        networkInterceptor.responses {
            StytchB2BClient.DiscoveryAuthenticateResponseData.mock
        }

        _ = try await client.discovery.authenticate(parameters: authParams)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/passwords/discovery/authenticate",
            method: .post([
                "email_address": "user@example.com",
                "password": "password123",
            ])
        )
    }
}
