import XCTest
@testable import StytchCore

final class B2BSearchManagerTestCase: BaseTestCase {
    func testSearchMember() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SearchManager.SearchMemberResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let emailAddress = "johndoe@foo.com"
        let organizationId = "abcd1234"
        let parameters = StytchB2BClient.SearchManager.SearchMemberParameters(emailAddress: emailAddress, organizationId: organizationId)
        _ = try await StytchB2BClient.searchManager.searchMember(searchMemberParameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/members/search",
            method: .post([
                "email_address": StytchCore.JSON.string(emailAddress),
                "organization_id": StytchCore.JSON.string(organizationId),
            ])
        )
    }

    func testSearchOrganizations() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SearchManager.SearchOrganizationResponse(
                requestId: "1234",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let organizationSlug = "1234"
        let parameters = StytchB2BClient.SearchManager.SearchOrganizationParameters(organizationSlug: organizationSlug)
        _ = try await StytchB2BClient.searchManager.searchOrganization(searchOrganizationParameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/search",
            method: .post([
                "organization_slug": StytchCore.JSON.string(organizationSlug),
            ])
        )
    }
}

extension StytchB2BClient.SearchManager.SearchMemberResponseData {
    static let mock: Self = .init(member: .mock)
}

extension StytchB2BClient.SearchManager.MemberSearchResponse {
    static let mock: Self = .init(status: "", name: "", memberPasswordId: "")
}

extension StytchB2BClient.SearchManager.SearchOrganizationResponseData {
    static let mock: Self = .init(organization: .mock)
}

extension StytchB2BClient.SearchManager.OrganizationSearchResponse {
    static let mock: Self = .init(
        organizationId: "1234",
        organizationName: "org foo",
        organizationLogoUrl: nil,
        ssoActiveConnections: nil,
        ssoDefaultConnectionId: nil,
        emailAllowedDomains: nil,
        emailJitProvisioning: nil,
        emailInvites: nil,
        authMethods: nil,
        allowedAuthMethods: nil
    )
}
