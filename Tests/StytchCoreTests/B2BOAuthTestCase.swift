@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

final class B2BOAuthTestCase: BaseTestCase {
    @available(tvOS 16.0, *)
    func testAuthenticate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.OAuth.OAuthAuthenticateResponse.mock
        }

        Current.timer = { _, _, _ in .init() }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try Current.pkcePairManager.generateAndReturnPKCECodePair()
        XCTAssertNotNil(Current.pkcePairManager.getPKCECodePair())

        _ = try await StytchB2BClient.oauth.authenticate(parameters: .init(oauthToken: "i-am-token", sessionDurationMinutes: 12, locale: .en))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/oauth/authenticate",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "session_duration_minutes": 12,
                "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "oauth_token": "i-am-token",
                "locale": "en",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())

        XCTAssertEqual(StytchB2BClient.lastAuthMethodUsed, StytchB2BClient.B2BAuthMethod.oauth)
    }

    func testAuthenticateFailsWithPKCE() async throws {
        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.oauth.authenticate(parameters: .init(oauthToken: "i-am-token", sessionDurationMinutes: 12)),
            StytchSDKError.missingPKCE
        )
    }

    @available(tvOS 16.0, *)
    func testDiscoveryAuthenticate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.DiscoveryAuthenticateResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .mock
            )
        }

        Current.timer = { _, _, _ in .init() }

        _ = try Current.pkcePairManager.generateAndReturnPKCECodePair()
        XCTAssertNotNil(Current.pkcePairManager.getPKCECodePair())

        _ = try await StytchB2BClient.oauth.discovery.authenticate(parameters: .init(discoveryOauthToken: "i-am-token"))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/oauth/discovery/authenticate",
            method: .post([
                "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "discovery_oauth_token": "i-am-token",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())
    }

    func testDiscoveryAuthenticateFailsWithPKCE() async throws {
        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.oauth.discovery.authenticate(parameters: .init(discoveryOauthToken: "i-am-token")),
            StytchSDKError.missingPKCE
        )
    }
}

extension StytchB2BClient.DiscoveryAuthenticateResponseData {
    static var mock: Self {
        .init(
            intermediateSessionToken: "",
            emailAddress: "",
            discoveredOrganizations: []
        )
    }
}

extension StytchB2BClient.OAuth.OAuthAuthenticateResponse {
    static let mock: Self = .init(
        requestId: "req_123",
        statusCode: 200,
        wrapped: .init(
            memberSession: .mock,
            memberId: "member_id_123",
            member: .mock,
            organization: .mock,
            sessionToken: "xyzasdf",
            sessionJwt: "i'mvalidjson",
            intermediateSessionToken: "cccccbgkvlhvciffckuevcevtrkjfkeiklvulgrrgvke",
            memberAuthenticated: false,
            mfaRequired: nil,
            primaryRequired: nil,
            providerValues: .mock,
            memberDevice: nil
        )
    )
}

extension OAuthProviderValues {
    static let mock: Self = .init(
        accessToken: "",
        idToken: "",
        refreshToken: nil,
        scopes: [],
        expiresAt: Date()
    )
}
