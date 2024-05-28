import XCTest
@testable import StytchCore

final class B2BOrganizationsTestCase: BaseTestCase {
    func testSync() throws {
        XCTAssertNil(StytchB2BClient.organizations.getSync())
        Current.localStorage.organization = .mock
        XCTAssertNotNil(StytchB2BClient.organizations.getSync())
    }

    func testGet() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.OrganizationResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(organization: .mock)
            )
        }
        XCTAssertNil(StytchB2BClient.organizations.getSync())
        let getOrganizationResponse = try await StytchB2BClient.organizations.get()
        XCTAssertNotNil(StytchB2BClient.organizations.getSync())
        XCTAssertEqual(getOrganizationResponse.organization.id, StytchB2BClient.organizations.getSync()?.id)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/organizations/me",
            method: .get
        )
    }

    func testUpdate() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.OrganizationResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(organization: .mock)
            )
        }
        XCTAssertNil(StytchB2BClient.organizations.getSync())
        let updateOrganizationResponse = try await StytchB2BClient.organizations.update(updateParameters: .init(organizationName: "foo bar"))
        XCTAssertNotNil(StytchB2BClient.organizations.getSync())
        XCTAssertEqual(updateOrganizationResponse.organization.id, StytchB2BClient.organizations.getSync()?.id)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/organizations/me",
            method: .put(["organization_name": "foo bar"])
        )
    }

    func testDelete() async throws {
        let organizationId = "orgid123"
        networkInterceptor.responses {
            StytchB2BClient.Organizations.OrganizationDeleteResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .init(organizationId: organizationId)
            )
        }
        let deleteOrganizationResponse = try await StytchB2BClient.organizations.delete()
        XCTAssertEqual(deleteOrganizationResponse.organizationId, organizationId)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://web.stytch.com/sdk/v1/b2b/organizations/me",
            method: .delete
        )
    }
}
