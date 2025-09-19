import XCTest
@testable import StytchCore

final class OAuthTestCase: BaseTestCase {
    func testApple() async throws {
        networkInterceptor.responses {
            StytchClient.OAuth.Apple.AuthenticateResponse(
                requestId: "",
                statusCode: 200,
                wrapped: .init(
                    user: .mock(userId: ""),
                    sessionToken: "",
                    sessionJwt: "",
                    session: .mock(userId: ""),
                    userDevice: nil,
                    userCreated: false
                )
            )
            StytchClient.UserManagement.UserResponse(requestId: "", statusCode: 200, wrapped: .mock(userId: ""))
        }
        Current.appleOAuthClient = .init { _, _ in .init(idToken: "id_token_123", name: .init(firstName: "user", lastName: nil)) }
        Current.timer = { _, _, _ in .init() }
        _ = try await StytchClient.oauth.apple.start(parameters: .init())

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/oauth/apple/id_token/authenticate",
            method: .post([
                "session_duration_minutes": 5,
                "nonce": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "id_token": "id_token_123",
            ])
        )

        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://api.stytch.com/sdk/v1/users/me",
            method: .put([
                "name": ["first_name": "user"],
            ])
        )

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.oauthApple)
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses { StytchClient.OAuth.OAuthAuthenticateResponse.mock }
        Current.timer = { _, _, _ in .init() }

        await XCTAssertThrowsErrorAsync(
            try await StytchClient.oauth.authenticate(parameters: .init(token: "i-am-token", sessionDurationMinutes: 12)),
            StytchSDKError.missingPKCE
        )

        _ = try Current.pkcePairManager.generateAndReturnPKCECodePair()
        XCTAssertNotNil(Current.pkcePairManager.getPKCECodePair())

        networkInterceptor.responses { StytchClient.OAuth.OAuthAuthenticateResponse.mock }
        _ = try await StytchClient.oauth.authenticate(parameters: .init(token: "i-am-token", sessionDurationMinutes: 12))

        try XCTAssertRequest(
            networkInterceptor.requests[1],
            urlString: "https://api.stytch.com/sdk/v1/oauth/authenticate",
            method: .post([
                "session_duration_minutes": 12,
                "code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "token": "i-am-token",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())

        XCTAssertEqual(StytchClient.lastAuthMethodUsed, StytchClient.ConsumerAuthMethod.oauth)
    }
}

#if !os(watchOS)
extension OAuthTestCase {
    @available(tvOS 16.0, *)
    func testThirdPartyASWebAuthSession() async throws {
        Current.webAuthenticationSessionClient = .init { params in
            ("random-token", try XCTUnwrap(URL(string: "\(params.callbackUrlScheme)://something")))
        }
        var baseUrl = try XCTUnwrap(URL(string: "https://blah"))

        // The internals prepend "provider_" to each key.
        // For example, if the developer passes in ["foo": "bar"],
        // the resulting dictionary will be:
        let providerParams = ["provider_foo": "bar"]

        let createConfiguration: (URL) -> StytchClient.OAuth.ThirdParty.WebAuthenticationConfiguration = { url in
            .init(
                loginRedirectUrl: url.appendingPathComponent("/login"),
                signupRedirectUrl: url.appendingPathComponent("/signup"),
                providerParams: ["foo": "bar"]
            )
        }

        let invalidStartParams = createConfiguration(baseUrl)

        try await StytchClient.OAuth.ThirdParty.Provider.allCases.asyncForEach { provider in
            await XCTAssertThrowsErrorAsync(
                try await provider.interface.start(configuration: invalidStartParams),
                StytchSDKError.invalidRedirectScheme
            )
        }

        baseUrl = try XCTUnwrap(URL(string: "custom-scheme://blah"))

        let validStartParams = createConfiguration(baseUrl)

        try await StytchClient.OAuth.ThirdParty.Provider.allCases.asyncForEach { provider in
            if let startUrl = try? validStartParams.startUrl(provider.rawValue) {
                assertURLContainsParameters(startUrl, expectedParameters: providerParams)
            } else {
                XCTFail("Failed to create start URL")
            }

            let (token, url) = try await provider.interface.start(configuration: validStartParams)
            XCTAssertEqual(token, "random-token")
            XCTAssertEqual(url.absoluteString, "custom-scheme://something")
        }
    }
}

private extension StytchClient.OAuth.ThirdParty.Provider {
    var interface: StytchClient.OAuth.ThirdParty {
        switch self {
        case .amazon:
            return StytchClient.oauth.amazon
        case .bitbucket:
            return StytchClient.oauth.bitbucket
        case .coinbase:
            return StytchClient.oauth.coinbase
        case .discord:
            return StytchClient.oauth.discord
        case .facebook:
            return StytchClient.oauth.facebook
        case .figma:
            return StytchClient.oauth.figma
        case .github:
            return StytchClient.oauth.github
        case .gitlab:
            return StytchClient.oauth.gitlab
        case .google:
            return StytchClient.oauth.google
        case .linkedin:
            return StytchClient.oauth.linkedin
        case .microsoft:
            return StytchClient.oauth.microsoft
        case .salesforce:
            return StytchClient.oauth.salesforce
        case .slack:
            return StytchClient.oauth.slack
        case .snapchat:
            return StytchClient.oauth.snapchat
        case .spotify:
            return StytchClient.oauth.spotify
        case .tiktok:
            return StytchClient.oauth.tiktok
        case .twitch:
            return StytchClient.oauth.twitch
        case .twitter:
            return StytchClient.oauth.twitter
        case .yahoo:
            return StytchClient.oauth.yahoo
        }
    }
}
#endif

extension StytchClient.OAuth.OAuthAuthenticateResponse {
    static let mock: Self = .init(
        requestId: "req_123",
        statusCode: 200,
        wrapped: .init(
            user: .mock(userId: "123"),
            sessionToken: "123",
            sessionJwt: "123",
            session: .mock(userId: "123"),
            userDevice: nil,
            oauthUserRegistrationId: "123",
            providerSubject: "123",
            providerType: "123",
            providerValues: .mock
        )
    )
}
