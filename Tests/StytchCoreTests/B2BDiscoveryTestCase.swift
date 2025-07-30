@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

final class B2BDiscoveryTestCase: BaseTestCase {
    private let client = StytchB2BClient.discovery

    func testListOrganizations() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Discovery.ListOrganizationsResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(
                    emailAddress: "blah@gmail.com",
                    discoveredOrganizations: [
                        .init(
                            organization: .mock,
                            membership: .init(type: .activeMember, details: nil, member: .mock),
                            memberAuthenticated: false,
                            mfaRequired: nil,
                            primaryRequired: nil
                        ),
                    ]
                )
            )
        }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)
        XCTAssertTrue(Current.sessionManager.hasValidIntermediateSessionToken)

        _ = try await client.listOrganizations()

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/discovery/organizations",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
            ])
        )
    }

    func testExchangeIntermediateSession() async throws {
        networkInterceptor.responses { B2BMFAAuthenticateResponse.mock }
        Current.timer = { _, _, _ in Self.mockTimer }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)
        XCTAssertTrue(Current.sessionManager.hasValidIntermediateSessionToken)

        _ = try await client.exchangeIntermediateSession(parameters: .init(organizationId: Organization.mock.id))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/discovery/intermediate_sessions/exchange",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "organization_id": "org_123",
                "session_duration_minutes": 5,
                "locale": "en",
            ])
        )
    }

    func testCreateOrganization() async throws {
        networkInterceptor.responses { B2BMFAAuthenticateResponse.mock }
        Current.timer = { _, _, _ in Self.mockTimer }

        Current.sessionManager.updateSession(intermediateSessionToken: intermediateSessionToken)
        XCTAssertTrue(Current.sessionManager.hasValidIntermediateSessionToken)

        _ = try await client.createOrganization(
            parameters: .init(
                sessionDurationMinutes: 12,
                organizationName: "hello",
                organizationSlug: "goodbye",
                organizationLogoUrl: XCTUnwrap(.init(string: "file://123")),
                ssoJitProvisioning: .allAllowed,
                emailAllowedDomains: ["something.com"],
                emailJitProvisioning: .notAllowed,
                emailInvites: .restricted,
                authMethods: .allAllowed,
                allowedAuthMethods: [.magicLink, .password]
            )
        )

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/discovery/organizations/create",
            method: .post([
                "intermediate_session_token": JSON(stringLiteral: intermediateSessionToken),
                "session_duration_minutes": 12,
                "organization_name": "hello",
                "organization_slug": "goodbye",
                "organization_logo_url": "file://123",
                "sso_jit_provisioning": "ALL_ALLOWED",
                "email_allowed_domains": ["something.com"],
                "email_jit_provisioning": "NOT_ALLOWED",
                "email_invites": "RESTRICTED",
                "auth_methods": "ALL_ALLOWED",
                "allowed_auth_methods": ["magic_link", "password"],
            ])
        )
    }
}
