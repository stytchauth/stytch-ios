import XCTest
@testable import StytchCore

#if !os(watchOS)
final class B2BSSOTestCase: BaseTestCase {
    @available(tvOS 16.0, *)
    func testStart() async throws {
        Current.webAuthSessionClient = .init { params in
            ("random-token", try XCTUnwrap(URL(string: "\(params.callbackUrlScheme)://something")))
        }
        var baseUrl = try XCTUnwrap(URL(string: "https://blah"))

        let createParams: (URL) -> StytchB2BClient.SSO.StartParameters = { url in
            .init(
                connectionId: "connection-id:123",
                loginRedirectUrl: url.appendingPathComponent("/login"),
                signupRedirectUrl: url.appendingPathComponent("/signup")
            )
        }

        let invalidStartParams = createParams(baseUrl)

        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.sso.start(parameters: invalidStartParams),
            StytchSDKError.invalidRedirectScheme
        )

        baseUrl = try XCTUnwrap(URL(string: "custom-scheme://blah"))

        let validStartParams = createParams(baseUrl)

        let (token, url) = try await StytchB2BClient.sso.start(parameters: validStartParams)
        XCTAssertEqual(token, "random-token")
        XCTAssertEqual(url.absoluteString, "custom-scheme://something")
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses { B2BAuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }

        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.sso.authenticate(parameters: .init(token: "i-am-token", sessionDuration: 12)),
            StytchSDKError.missingPKCE
        )
        _ = try StytchB2BClient.generateAndStorePKCE(keychainItem: .codeVerifierPKCE)
        _ = try await StytchB2BClient.sso.authenticate(parameters: .init(token: "i-am-token", sessionDuration: 12))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/sso/authenticate",
            method: .post([
                "session_duration_minutes": 12,
                "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "sso_token": "i-am-token",
            ])
        )
    }
}
#endif
