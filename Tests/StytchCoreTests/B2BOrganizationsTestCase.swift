import XCTest
@testable import StytchCore

final class B2BOrganizationsTestCase: BaseTestCase {
    func testSync() throws {
        XCTAssertNil(StytchB2BClient.organization.getSync())
        Current.localStorage.organization = .mock
        XCTAssertNotNil(StytchB2BClient.organization.getSync())
    }

    func testGet() async throws {
        networkInterceptor.responses { StytchB2BClient.Organizations.OrganizationResponse(requestId: "123", statusCode: 200, wrapped: .init(organization: .mock)) }
        XCTAssertNil(StytchB2BClient.organization.getSync())
        let getOrganizationResponse = try await StytchB2BClient.organization.get()
        XCTAssertNotNil(StytchB2BClient.organization.getSync())
        XCTAssertEqual(getOrganizationResponse.organization.id, StytchB2BClient.organization.getSync()?.id)
        try XCTAssertRequest(networkInterceptor.requests[0], urlString: "https://web.stytch.com/sdk/v1/b2b/organizations/me", method: .get)
    }
}
