import XCTest
@testable import StytchCore

final class PasswordsTestCase: BaseTestCase {
    private let passwordParams: StytchClient.Passwords.PasswordParameters = .init(email: "user@stytch.com", password: "password123", sessionDuration: 26)

    func testCreate() async throws {
        var request: URLRequest?
        let userId = "user_id_123"
        let data = try Current.jsonEncoder.encode(DataContainer(data: StytchClient.Passwords.CreateResponse(requestId: "321", statusCode: 200, wrapped: .init(emailId: "email_id_that's_what_i_am", userId: userId, user: .mock(userId: userId), sessionToken: "session_token_431", sessionJwt: "jwt_8534", session: .mock(userId: userId)))))
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        Current.timer = { _, _, _ in .init() }
        _ = try await StytchClient.passwords.create(parameters: passwordParams)

        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/passwords")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"email\":\"user@stytch.com\",\"session_duration_minutes\":26,\"password\":\"password123\"}".utf8))
    }

    func testAuthenticate() async throws {
        var request: URLRequest?
        let data = try Current.jsonEncoder.encode(DataContainer(data: AuthenticateResponse.mock))
        Current.timer = { _, _, _ in .init() }
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        _ = try await StytchClient.passwords.authenticate(parameters: passwordParams)

        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/passwords/authenticate")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"email\":\"user@stytch.com\",\"session_duration_minutes\":26,\"password\":\"password123\"}".utf8))
    }

    func testStrengthCheck() async throws {
        var request: URLRequest?
        let data = try Current.jsonEncoder.encode(DataContainer(data: StytchClient.Passwords.StrengthCheckResponse(requestId: "123", statusCode: 200, wrapped: .init(validPassword: false, score: 20, breachedPassword: true, feedback: .init(suggestions: [], warning: "meh. do something.")))))
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(data))
        _ = try await StytchClient.passwords.strengthCheck(parameters: StytchClient.Passwords.StrengthCheckParameters(email: nil, password: "p@ssword123"))

        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/passwords/strength_check")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"password\":\"p@ssword123\"}".utf8))
    }

    func testReset() async throws {
        await XCTAssertThrowsError(_ = try await StytchClient.passwords.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR")))

        var request: URLRequest?
        let startData = try Current.jsonEncoder.encode(DataContainer(data: BasicResponse(requestId: "123", statusCode: 200)))
        let finishData = try Current.jsonEncoder.encode(DataContainer(data: AuthenticateResponse.mock))
        Current.networkingClient = .mock(verifyingRequest: { request = $0 }, returning: .success(startData), .success(finishData))
        _ = try await StytchClient.passwords.resetByEmailStart(parameters: .init(email: "user@stytch.com", loginUrl: nil, loginExpiration: nil, resetPasswordUrl: XCTUnwrap(URL(string: "https://stytch.com/reset")), resetPasswordExpiration: 15))

        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/passwords/email/reset/start")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"email\":\"user@stytch.com\",\"reset_password_redirect_url\":\"https:\\/\\/stytch.com\\/reset\",\"reset_password_expiration_minutes\":15,\"code_challenge\":\"V9dLhNVhiUv_9m8cwFSzLGR9l-q6NAeLskiVZ7WsjA8\",\"code_challenge_method\":\"S256\"}".utf8))

        Current.timer = { _, _, _ in .init() }

        _ = try await StytchClient.passwords.resetByEmail(parameters: .init(token: "12345", password: "iAMpasswordHEARmeROAR"))

        XCTAssertEqual(request?.url?.absoluteString, "https://web.stytch.com/sdk/v1/passwords/email/reset")
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.httpBody, Data("{\"token\":\"12345\",\"code_verifier\":\"e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741\",\"password\":\"iAMpasswordHEARmeROAR\"}".utf8))
    }
}
