import Combine
import XCTest
@testable import StytchCore

// swiftlint:disable multiline_function_chains

final class B2BOrganizationsTestCase: BaseTestCase {
    var subscriptions: Set<AnyCancellable> = []

    func testSync() throws {
        XCTAssertNil(StytchB2BClient.organizations.getSync())
        Current.organizationStorage.update(.mock)
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
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me",
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
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me",
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
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me",
            method: .delete
        )
    }

    func testSearchMembers() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let query = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .AND,
            searchOperands: []
        )

        let parameters = StytchB2BClient.Organizations.SearchParameters(
            query: query,
            cursor: nil,
            limit: nil
        )

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: parameters)
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me/members/search",
            method: .post([
                "query": StytchCore.JSON.object(
                    [
                        "operator": StytchCore.JSON.string("AND"),
                        "operands": StytchCore.JSON.array([]),
                    ]
                ),
            ])
        )
    }

    func testOrganizationPublisherAvailable() throws {
        let expectation = XCTestExpectation(description: "onOrganizationChange completes")
        var receivedOrganization: Organization?
        var receivedDate: Date?

        StytchB2BClient.organizations.onOrganizationChange.sink { organizationInfo in
            switch organizationInfo {
            case let .available(organization, lastValidatedAtDate):
                receivedOrganization = organization
                receivedDate = lastValidatedAtDate
                expectation.fulfill()
            case .unavailable:
                break
            }
        }.store(in: &subscriptions)

        Current.organizationStorage.update(.mock)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedOrganization)
        XCTAssertNotNil(receivedDate)
    }

    func testOrganizationPublisherUnavailable() throws {
        let expectation = XCTestExpectation(description: "onOrganizationChange completes")

        StytchB2BClient.organizations.onOrganizationChange.sink { organizationInfo in
            switch organizationInfo {
            case .available:
                break
            case .unavailable:
                expectation.fulfill()
            }
        }.store(in: &subscriptions)

        Current.organizationStorage.update(nil)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(StytchB2BClient.organizations.getSync())
    }
}

extension StytchB2BClient.Organizations.SearchResponseData {
    static let mock: Self = .init(
        members: [.mock],
        resultsMetadata: .mock,
        organizations: ["org123": .mock]
    )
}

extension StytchB2BClient.Organizations.SearchResponseResultsMetadata {
    static let mock: Self = .init(
        total: 10,
        nextCursor: nil
    )
}
