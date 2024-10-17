@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

#if !os(watchOS)
final class B2BSSOTestCase: BaseTestCase {
    @available(tvOS 16.0, *)
    func testStart() async throws {
        Current.webAuthenticationSessionClient = .init { params in
            ("random-token", try XCTUnwrap(URL(string: "\(params.callbackUrlScheme)://something")))
        }
        var baseUrl = try XCTUnwrap(URL(string: "https://blah"))

        let createConfiguration: (URL) -> StytchB2BClient.SSO.WebAuthenticationConfiguration = { url in
            .init(
                connectionId: "connection-id:123",
                loginRedirectUrl: url.appendingPathComponent("/login"),
                signupRedirectUrl: url.appendingPathComponent("/signup")
            )
        }

        let invalidStartParams = createConfiguration(baseUrl)

        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.sso.start(configuration: invalidStartParams),
            StytchSDKError.invalidRedirectScheme
        )

        baseUrl = try XCTUnwrap(URL(string: "custom-scheme://blah"))

        let validStartParams = createConfiguration(baseUrl)

        let (token, url) = try await StytchB2BClient.sso.start(configuration: validStartParams)
        XCTAssertEqual(token, "random-token")
        XCTAssertEqual(url.absoluteString, "custom-scheme://something")
    }

    func testAuthenticate() async throws {
        networkInterceptor.responses {
            B2BMFAAuthenticateResponse.mock
        }
        Current.timer = { _, _, _ in .init() }

        await XCTAssertThrowsErrorAsync(
            try await StytchB2BClient.sso.authenticate(parameters: .init(token: "i-am-token", sessionDuration: 12, locale: .en)),
            StytchSDKError.missingPKCE
        )

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)

        _ = try Current.pkcePairManager.generateAndReturnPKCECodePair()
        XCTAssertNotNil(Current.pkcePairManager.getPKCECodePair())

        _ = try await StytchB2BClient.sso.authenticate(parameters: .init(token: "i-am-token", sessionDuration: 12, locale: .en))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/authenticate",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "session_duration_minutes": 12,
                "pkce_code_verifier": "e0683c9c02bf554ab9c731a1767bc940d71321a40fdbeac62824e7b6495a8741",
                "sso_token": "i-am-token",
                "locale": "en",
            ])
        )

        XCTAssertNil(Current.pkcePairManager.getPKCECodePair())
    }

    func testGetConnections() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.GetConnectionsResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    samlConnections: [.mock],
                    oidcConnections: [.mock]
                )
            )
        }

        _ = try await StytchB2BClient.sso.getConnections()
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso",
            method: .get
        )
    }

    func testDeleteConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.DeleteConnectionResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    connectionId: "1234"
                )
            )
        }
        let connectionId = "1234"
        _ = try await StytchB2BClient.sso.deleteConnection(connectionId: connectionId)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/\(connectionId)",
            method: .delete
        )
    }

    func testCreateOIDCConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.OIDC.OIDCConnectionResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    connection: .mock
                )
            )
        }

        let displayName = "foo bar"
        let identityProvider = "identityProvider1234"
        let parameters = StytchB2BClient.SSO.OIDC.CreateConnectionParameters(displayName: displayName, identityProvider: identityProvider)
        _ = try await StytchB2BClient.sso.oidc.createConnection(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/oidc",
            method: .post(["display_name": JSON(stringLiteral: displayName), "identity_provider": JSON(stringLiteral: identityProvider)])
        )
    }

    func testUpdateOIDCConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.OIDC.OIDCConnectionResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    connection: .mock
                )
            )
        }

        let connectionId = "1234"
        let parameters = StytchB2BClient.SSO.OIDC.UpdateConnectionParameters(connectionId: connectionId)
        _ = try await StytchB2BClient.sso.oidc.updateConnection(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/oidc/\(connectionId)",
            method: .put(["connection_id": JSON(stringLiteral: connectionId)])
        )
    }

    func testCreateSAMLConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.SAML.SAMLConnectionResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    connection: .mock
                )
            )
        }

        let displayName = "foo bar"
        let identityProvider = "identityProvider1234"
        let parameters = StytchB2BClient.SSO.SAML.CreateConnectionParameters(displayName: displayName, identityProvider: identityProvider)
        _ = try await StytchB2BClient.sso.saml.createConnection(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/saml",
            method: .post(["display_name": JSON(stringLiteral: displayName), "identity_provider": JSON(stringLiteral: identityProvider)])
        )
    }

    func testUpdateSAMLConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.SAML.SAMLConnectionResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    connection: .mock
                )
            )
        }

        let connectionId = "1234"
        let parameters = StytchB2BClient.SSO.SAML.UpdateConnectionParameters(connectionId: connectionId)
        _ = try await StytchB2BClient.sso.saml.updateConnection(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/saml/\(connectionId)",
            method: .put(["connection_id": JSON(stringLiteral: connectionId)])
        )
    }

    func testUpdateSAMLConnectionByURL() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.SAML.SAMLConnectionResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    connection: .mock
                )
            )
        }

        let connectionId = "1234"
        let metadataUrl = "http://www.google.com"
        let parameters = StytchB2BClient.SSO.SAML.UpdateConnectionByURLParameters(connectionId: connectionId, metadataUrl: metadataUrl)
        _ = try await StytchB2BClient.sso.saml.updateConnectionByURL(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/saml/\(connectionId)/url",
            method: .put(["connection_id": JSON(stringLiteral: connectionId), "metadata_url": JSON(stringLiteral: metadataUrl)])
        )
    }

    func testDeleteSAMLVerificationCertificate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SSO.SAML.SAMLDeleteVerificationCertificateResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .init(
                    certificateId: "1234"
                )
            )
        }

        let connectionId = "connectionId1234"
        let certificateId = "certificateId1234"
        let parameters = StytchB2BClient.SSO.SAML.DeleteVerificationCertificateParameters(connectionId: connectionId, certificateId: certificateId)
        _ = try await StytchB2BClient.sso.saml.deleteVerificationCertificate(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/sso/saml/\(connectionId)/verification_certificates/\(certificateId)",
            method: .delete
        )
    }
}

extension StytchB2BClient.SSO.SAML.SAMLConnection {
    static var mock: Self {
        .init(
            organizationId: "",
            connectionId: "",
            status: "",
            attributeMapping: [:],
            idpEntityId: "",
            displayName: "",
            idpSsoUrl: "",
            acsUrl: "",
            audienceUri: "",
            signingCertificates: [],
            verificationCertificates: [],
            samlConnectionImplicitRoleAssignments: [],
            samlGroupImplicitRoleAssignments: [],
            identityProvider: ""
        )
    }
}

extension StytchB2BClient.SSO.OIDC.OIDCConnection {
    static var mock: Self {
        .init(
            organizationId: "",
            connectionId: "",
            status: "",
            displayName: "",
            redirectUrl: "",
            issuer: "",
            clientId: "",
            clientSecret: "",
            authorizationUrl: "",
            tokenUrl: "",
            userinfoUrl: "",
            jwksUrl: "",
            identityProvider: ""
        )
    }
}

#endif
