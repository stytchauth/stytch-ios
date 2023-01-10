import XCTest
@testable import StytchCore

final class PasswordsTestCase: BaseTestCase {
    private let passwordParams: StytchClient.Passwords.PasswordParameters = .init(email: "user@stytch.com", password: "password123", sessionDuration: 26)

    func testCreate() async throws {
        let userId: User.ID = ""
        networkInterceptor.responses {
            StytchClient.Passwords.CreateResponse(requestId: "321", statusCode: 200, wrapped: .init(emailId: "email_id_that's_what_i_am", userId: userId, user: .mock(userId: userId), sessionToken: "session_token_431", sessionJwt: "jwt_8534", session: .mock(userId: userId)))
        }
        Current.timer = { _, _, _ in .init() }
        _ = try await StytchClient.passwords.create(parameters: passwordParams)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/passwords",
            method: .post([
                "email": "user@stytch.com",
                "session_duration_minutes": 26,
                "password": "password123",
            ])
        )
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses { AuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }
        _ = try await StytchClient.passwords.authenticate(parameters: passwordParams)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/passwords/authenticate",
            method: .post([
                "email": "user@stytch.com",
                "session_duration_minutes": 26,
                "password": "password123",
            ])
        )
    }

    func testStrengthCheck() async throws {
        networkInterceptor.responses {
            StytchClient.Passwords.StrengthCheckResponse(requestId: "123", statusCode: 200, wrapped: .init(validPassword: false, score: 20, breachedPassword: true, feedback: .init(suggestions: [], warning: "meh. do something.")))
        }
        _ = try await StytchClient.passwords.strengthCheck(parameters: StytchClient.Passwords.StrengthCheckParameters(email: nil, password: "p@ssword123"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/passwords/strength_check",
            method: .post([
                "password": "p@ssword123",
            ])
        )
    }

    func testReset() async throws {
        await XCTAssertThrowsErrorAsync(_ = try await StytchClient.passwords.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR")))

        networkInterceptor.responses {
            BasicResponse(requestId: "123", statusCode: 200)
            AuthenticateResponse.mock
        }
        _ = try await StytchClient.passwords.resetByEmailStart(parameters: .init(email: "user@stytch.com", loginUrl: nil, loginExpiration: nil, resetPasswordUrl: XCTUnwrap(URL(string: "https://stytch.com/reset")), resetPasswordExpiration: 15))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/passwords/email/reset/start",
            method: .post([
                "email": "user@stytch.com",
                "reset_password_expiration_minutes": 15,
                "reset_password_redirect_url": "https://stytch.com/reset",
                "code_challenge": "V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8",
                "code_challenge_method": "S256",
            ])
        )

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.passwords.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR"))

        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://web.stytch.com/sdk/v1/passwords/email/reset",
            method: .post([
                "token": "12345",
                "code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "session_duration_minutes": 30,
                "password": "iAMpasswordHEARmeROAR",
            ])
        )
    }
}
