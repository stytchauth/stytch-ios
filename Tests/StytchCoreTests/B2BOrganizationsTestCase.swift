import Combine
@preconcurrency import SwiftyJSON
import XCTest
@testable import StytchCore

// swiftlint:disable multiline_function_chains vertical_parameter_alignment_on_call

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

// These tests cover the search members functionality for organizations.
// Specifically, they validate that:
// - Different operand types (boolean, string, string array) are encoded and sent correctly in requests.
// - Query operators (AND, OR) are properly handled.
// - Nil and empty values for query parameters are encoded as expected (e.g., JSON null).
// - The operand factory rejects operands with mismatched types.
// The tests ensure robust encoding and correct request construction for searching organization members.
extension B2BOrganizationsTestCase {
    // Verifies that a boolean operand search with AND operator is encoded and sent correctly.
    func testSearchMembers() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let filterName = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandFilterNames.memberIsBreakglass.rawValue
        let boolOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandBool(
            filterName: filterName,
            filterValue: true
        )
        let query = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .AND,
            searchOperands: [boolOperand]
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
                "query": JSON(dictionaryLiteral:
                    ("operator", JSON(stringLiteral: "AND").rawValue),
                    ("operands", JSON(arrayLiteral: boolOperand.json).rawValue)),
            ])
        )
    }

    // Verifies that a boolean operand with value true is encoded and sent correctly.
    func testSearchMembersBoolOperandTrue() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "id",
                statusCode: 200,
                wrapped: .mock
            )
        }

        let boolOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandBool(
            filterName: "member_is_breakglass",
            filterValue: true
        )
        let searchQuery = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .AND,
            searchOperands: [boolOperand]
        )
        let searchParameters = StytchB2BClient.Organizations.SearchParameters(query: searchQuery)

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: searchParameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me/members/search",
            method: .post([
                "query": JSON(dictionaryLiteral:
                    ("operator", JSON(stringLiteral: "AND").rawValue),
                    ("operands", JSON(arrayLiteral: boolOperand.json).rawValue)),
            ])
        )
    }

    // Verifies that an empty array operand for member_emails is encoded and sent correctly.
    func testSearchMembersMemberEmailsEmptyArray() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "id",
                statusCode: 200,
                wrapped: .mock
            )
        }
        let stringArrayOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandStringArray(
            filterName: "member_emails",
            filterValue: []
        )
        let searchQuery = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .AND,
            searchOperands: [stringArrayOperand]
        )
        let searchParameters = StytchB2BClient.Organizations.SearchParameters(query: searchQuery)

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: searchParameters)

        let expected = JSON(dictionaryLiteral:
            ("operator", JSON(stringLiteral: "AND").rawValue),
            ("operands", JSON(arrayLiteral: stringArrayOperand.json).rawValue))
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me/members/search",
            method: .post(["query": expected])
        )
    }

    // Verifies that a non-empty array operand for member_emails is encoded and sent correctly.
    func testSearchMembersMemberEmailsNonEmpty() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "id",
                statusCode: 200,
                wrapped: .mock
            )
        }
        let stringArrayOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandStringArray(
            filterName: "member_emails",
            filterValue: ["a@x.com", "b@x.com"]
        )
        let searchQuery = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .AND,
            searchOperands: [stringArrayOperand]
        )
        let searchParameters = StytchB2BClient.Organizations.SearchParameters(query: searchQuery)

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: searchParameters)

        let expected = JSON(dictionaryLiteral:
            ("operator", JSON(stringLiteral: "AND").rawValue),
            ("operands", JSON(arrayLiteral: stringArrayOperand.json).rawValue))
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me/members/search",
            method: .post(["query": expected])
        )
    }

    // Verifies that a single string operand for member_email_fuzzy is encoded and sent correctly.
    func testSearchMembersMemberEmailFuzzySingleString() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "id",
                statusCode: 200,
                wrapped: .mock
            )
        }
        let stringOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandString(
            filterName: "member_email_fuzzy",
            filterValue: "alice"
        )
        let searchQuery = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .OR,
            searchOperands: [stringOperand]
        )
        let searchParameters = StytchB2BClient.Organizations.SearchParameters(query: searchQuery)

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: searchParameters)

        let expected = JSON(dictionaryLiteral:
            ("operator", JSON(stringLiteral: "OR").rawValue),
            ("operands", JSON(arrayLiteral: stringOperand.json).rawValue))
        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me/members/search",
            method: .post(["query": expected])
        )
    }

    // Verifies that multiple operands (string array and bool) with AND operator, cursor, and limit are encoded and sent correctly.
    func testSearchMembersMultipleOperandsAnd() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "id",
                statusCode: 200,
                wrapped: .mock
            )
        }
        let stringArrayOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandStringArray(
            filterName: "member_emails",
            filterValue: ["a@x.com"]
        )
        let boolOperand = StytchB2BClient.Organizations.SearchParameters.SearchQueryOperandBool(
            filterName: "member_password_exists",
            filterValue: true
        )
        let searchQuery = StytchB2BClient.Organizations.SearchParameters.SearchQuery(
            searchOperator: .AND,
            searchOperands: [stringArrayOperand, boolOperand]
        )
        let searchParameters = StytchB2BClient.Organizations.SearchParameters(
            query: searchQuery,
            cursor: "c123",
            limit: 50
        )

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: searchParameters)

        let expectedQuery = JSON(dictionaryLiteral:
            ("operator", JSON(stringLiteral: "AND").rawValue),
            ("operands", JSON(arrayLiteral: stringArrayOperand.json, boolOperand.json).rawValue))

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/organizations/me/members/search",
            method: .post([
                "query": expectedQuery,
                "cursor": JSON(stringLiteral: "c123").rawValue,
                "limit": JSON(integerLiteral: 50).rawValue,
            ])
        )
    }

    // Verifies that a nil query parameter is encoded as a JSON null value.
    func testSearchMembersNilQueryEncodesAsNull() async throws {
        networkInterceptor.responses {
            StytchB2BClient.Organizations.SearchMembersResponse(
                requestId: "id",
                statusCode: 200,
                wrapped: .mock
            )
        }
        let searchParameters = StytchB2BClient.Organizations.SearchParameters(
            query: nil,
            cursor: nil,
            limit: nil
        )

        _ = try await StytchB2BClient.organizations.searchMembers(parameters: searchParameters)

        let body = try XCTUnwrap(networkInterceptor.requests.first?.httpBody)
        let json = try JSON(data: body)
        XCTAssertEqual(json["query"].type, .null)
    }

    // Verifies that the factory rejects operands with mismatched types.
    func testSearchMembersFactoryRejectsMismatchedTypes() {
        let invalidStringArrayOperand = StytchB2BClient.Organizations.SearchParameters.searchQueryOperand(
            filterName: .memberEmailFuzzy,
            filterValue: ["not single string"]
        )
        XCTAssertNil(invalidStringArrayOperand)

        let invalidBoolOperand = StytchB2BClient.Organizations.SearchParameters.searchQueryOperand(
            filterName: .memberIsBreakglass,
            filterValue: "not bool"
        )
        XCTAssertNil(invalidBoolOperand)
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
