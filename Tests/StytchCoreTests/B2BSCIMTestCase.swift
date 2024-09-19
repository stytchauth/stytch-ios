import XCTest
@testable import StytchCore

final class B2BSCIMTestCase: BaseTestCase {
    func testCreateConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMCreateConnectionResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMCreateConnectionResponseData(connection: .mock)
            )
        }

        let parameters = StytchB2BClient.SCIM.CreateConnectionParameters(displayName: "A New SCIM Connection!", identityProvider: nil)
        _ = try await StytchB2BClient.scim.createConnection(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim",
            method: .post(["display_name": JSON.string("A New SCIM Connection!")])
        )
    }

    func testUpdateConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMUpdateConnectionResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMUpdateConnectionResponseData(connection: .mock)
            )
        }

        let connectionId = "connectionId"

        let parameters = StytchB2BClient.SCIM.UpdateConnectionParameters(
            connectionId: connectionId,
            displayName: "A Updated SCIM Connection!",
            identityProvider: nil,
            scimGroupImplicitRoleAssignments: nil
        )
        _ = try await StytchB2BClient.scim.updateConnection(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim/\(connectionId)",
            method: .put(["connection_id": JSON.string("connectionId"), "display_name": JSON.string("A Updated SCIM Connection!")])
        )
    }

    func testDeleteConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMDeleteConnectionResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMDeleteConnectionResponseData(connectionId: "connectionId")
            )
        }

        let connectionId = "connectionId"

        _ = try await StytchB2BClient.scim.deleteConnection(connectionId: connectionId)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim/\(connectionId)",
            method: .delete
        )
    }

    func testGetConnection() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMGetConnectionResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMGetConnectionResponseData(connection: .mock)
            )
        }

        _ = try await StytchB2BClient.scim.getConnection()

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim",
            method: .get
        )
    }

    func testGetConnectionGroups() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMGetConnectionGroupsResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMGetConnectionGroupsResponseData(scimGroups: [.mock], nextCursor: nil)
            )
        }

        let parameters = StytchB2BClient.SCIM.GetConnectionGroupsParameters(limit: nil, cursor: nil)
        _ = try await StytchB2BClient.scim.getConnectionGroups(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim",
            method: .post([:])
        )
    }

    func testRotateStart() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMRotateStartResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMRotateStartResponseData(connection: .mock)
            )
        }

        let connectionId = "connectionId"

        let parameters = StytchB2BClient.SCIM.RotateParameters(connectionId: connectionId)
        _ = try await StytchB2BClient.scim.rotateStart(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim/rotate/start",
            method: .post(["connection_id": JSON.string("connectionId")])
        )
    }

    func testRotateComplete() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMRotateCompleteResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMRotateCompleteResponseData(connection: .mock)
            )
        }

        let connectionId = "connectionId"

        let parameters = StytchB2BClient.SCIM.RotateParameters(connectionId: connectionId)
        _ = try await StytchB2BClient.scim.rotateComplete(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim/rotate/complete",
            method: .post(["connection_id": JSON.string("connectionId")])
        )
    }

    func testRotateCancel() async throws {
        networkInterceptor.responses {
            StytchB2BClient.SCIM.SCIMRotateCancelResponse(
                requestId: "123",
                statusCode: 200,
                wrapped: StytchB2BClient.SCIM.SCIMRotateCancelResponseData(connection: .mock)
            )
        }

        let connectionId = "connectionId"

        let parameters = StytchB2BClient.SCIM.RotateParameters(connectionId: connectionId)
        _ = try await StytchB2BClient.scim.rotateCancel(parameters: parameters)

        try XCTAssertRequest(
            networkInterceptor.requests[0],
            urlString: "https://api.stytch.com/sdk/v1/b2b/scim/rotate/cancel",
            method: .post(["connection_id": JSON.string("connectionId")])
        )
    }
}

public extension StytchB2BClient.SCIM.SCIMConnection {
    static var mock: Self {
        .init(
            organizationId: "orgid1234",
            connectionId: "connectionId1234",
            status: "",
            displayName: "scim connection name",
            identityProvider: "",
            baseUrl: "",
            scimGroupImplicitRoleAssignments: [],
            bearerTokenExpiresAt: "",
            bearerTokenLastFour: "",
            nextBearerTokenLastFour: nil,
            nextBearerTokenExpiresAt: nil
        )
    }
}

public extension StytchB2BClient.SCIM.SCIMConnectionWithBearerToken {
    static var mock: Self {
        .init(
            organizationId: "orgid1234",
            connectionId: "connectionId1234",
            status: "",
            displayName: "scim connection name",
            identityProvider: "",
            baseUrl: "",
            scimGroupImplicitRoleAssignments: [],
            bearerToken: "",
            bearerTokenExpiresAt: ""
        )
    }
}

public extension StytchB2BClient.SCIM.SCIMConnectionWithNextBearerToken {
    static var mock: Self {
        .init(
            organizationId: "orgid1234",
            connectionId: "connectionId1234",
            status: "",
            displayName: "scim connection name",
            identityProvider: "",
            baseUrl: "",
            scimGroupImplicitRoleAssignments: [],
            bearerTokenExpiresAt: "",
            bearerTokenLastFour: "",
            nextBearerToken: "",
            nextBearerTokenExpiresAt: ""
        )
    }
}

public extension StytchB2BClient.SCIM.SCIMGroupImplicitRoleAssignment {
    static var mock: Self {
        .init(
            roleId: "roleId-1234",
            groupId: "groupId-1234"
        )
    }
}

public extension StytchB2BClient.SCIM.SCIMGroup {
    static var mock: Self {
        .init(
            organizationId: "",
            connectionId: "connectionId1234",
            groupId: "groupId-1234",
            groupName: "groupName-1234"
        )
    }
}
