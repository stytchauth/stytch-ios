import Foundation

public extension StytchB2BClient.SCIM {
    typealias SCIMCreateConnectionResponse = Response<SCIMCreateConnectionResponseData>
    typealias SCIMUpdateConnectionResponse = Response<SCIMUpdateConnectionResponseData>
    typealias SCIMDeleteConnectionResponse = Response<SCIMDeleteConnectionResponseData>
    typealias SCIMGetConnectionResponse = Response<SCIMGetConnectionResponseData>
    typealias SCIMGetConnectionGroupsResponse = Response<SCIMGetConnectionGroupsResponseData>
    typealias SCIMRotateStartResponse = Response<SCIMRotateStartResponseData>
    typealias SCIMRotateCompleteResponse = Response<SCIMRotateCompleteResponseData>
    typealias SCIMRotateCancelResponse = Response<SCIMRotateCancelResponseData>
}

public extension StytchB2BClient.SCIM {
    struct SCIMConnection: Codable {
        /// Globally unique UUID that identifies a specific Organization.
        public let organizationId: String
        /// Globally unique UUID that identifies a specific SCIM Connection.
        public let connectionId: String
        /// The status of the connection. The possible values are deleted or active.
        public let status: String
        /// A human-readable display name for the connection.
        public let displayName: String
        /// The identity provider of this connection.
        public let identityProvider: String
        /// The base URL of the SCIM connection.
        public let baseUrl: String
        /// An array of implicit group role assignments granted to members in this organization who are provisioned this SCIM connection and belong to the specified group.
        /// See our RBAC guide (https://stytch.com/docs/b2b/guides/rbac/role-assignment) for more information about role assignment.
        public let scimGroupImplicitRoleAssignments: [SCIMGroupImplicitRoleAssignment]
        /// The time at which the bearer token expires.
        public let bearerTokenExpiresAt: String
        /// Last four characters of the issued bearer token.
        public let bearerTokenLastFour: String
        /// Present during rotation, the next bearer token's last four digits.
        public let nextBearerTokenLastFour: String?
        /// Present during rotation, the time at which the next bearer token expires.
        public let nextBearerTokenExpiresAt: String?
    }

    struct SCIMConnectionWithBearerToken: Codable {
        /// Globally unique UUID that identifies a specific Organization.
        public let organizationId: String
        /// Globally unique UUID that identifies a specific SCIM Connection.
        public let connectionId: String
        /// The status of the connection. The possible values are deleted or active.
        public let status: String
        /// A human-readable display name for the connection.
        public let displayName: String
        /// The identity provider of this connection.
        public let identityProvider: String
        /// The base URL of the SCIM connection.
        public let baseUrl: String
        /// An array of implicit group role assignments granted to members in this organization who are provisioned this SCIM connection and belong to the specified group.
        /// See our RBAC guide (https://stytch.com/docs/b2b/guides/rbac/role-assignment) for more information about role assignment.
        public let scimGroupImplicitRoleAssignments: [SCIMGroupImplicitRoleAssignment]
        /// The bearer token used to authenticate with the SCIM API.
        public let bearerToken: String
        /// The time at which the bearer token expires.
        public let bearerTokenExpiresAt: String
    }

    struct SCIMConnectionWithNextBearerToken: Codable {
        /// Globally unique UUID that identifies a specific Organization.
        public let organizationId: String
        /// Globally unique UUID that identifies a specific SCIM Connection.
        public let connectionId: String
        /// The status of the connection. The possible values are deleted or active.
        public let status: String
        /// A human-readable display name for the connection.
        public let displayName: String
        /// The identity provider of this connection.
        public let identityProvider: String
        /// The base URL of the SCIM connection.
        public let baseUrl: String
        /// An array of implicit group role assignments granted to members in this organization who are provisioned this SCIM connection and belong to the specified group.
        /// See our RBAC guide (https://stytch.com/docs/b2b/guides/rbac/role-assignment) for more information about role assignment.
        public let scimGroupImplicitRoleAssignments: [SCIMGroupImplicitRoleAssignment]
        /// The time at which the bearer token expires.
        public let bearerTokenExpiresAt: String
        /// Last four characters of the issued bearer token.
        public let bearerTokenLastFour: String
        /// The bearer token used to authenticate with the SCIM API.
        public let nextBearerToken: String
        /// Present during rotation, the time at which the next bearer token expires.
        public let nextBearerTokenExpiresAt: String
    }

    struct SCIMGroupImplicitRoleAssignment: Codable {
        /// The ID of the role.
        public let roleId: String
        /// The ID of the group.
        public let groupId: String
    }

    struct SCIMGroup: Codable {
        /// Globally unique UUID that identifies a specific Organization.
        public let organizationId: String
        /// Globally unique UUID that identifies a specific SCIM Connection.
        public let connectionId: String
        /// Globally unique UUID that identifies a specific SCIM Group.
        public let groupId: String
        /// Name given to the group by the IDP.
        public let groupName: String
    }

    struct SCIMCreateConnectionResponseData: Codable {
        /// The SCIM Connection object affected by this API call.
        public let connection: SCIMConnectionWithBearerToken
    }

    struct SCIMUpdateConnectionResponseData: Codable {
        /// The SCIM Connection object affected by this API call.
        public let connection: SCIMConnection
    }

    struct SCIMDeleteConnectionResponseData: Codable {
        /// lobally unique UUID that identifies a specific SCIM Connection.
        public let connectionId: String
    }

    struct SCIMGetConnectionResponseData: Codable {
        /// The SCIM Connection object affected by this API call.
        public let connection: SCIMConnection
    }

    struct SCIMGetConnectionGroupsResponseData: Codable {
        /// List of SCIM Groups for the connection.
        public let scimGroups: [SCIMGroup]?
        /// The cursor to use to get the next page of results.
        public let nextCursor: String?
    }

    struct SCIMRotateStartResponseData: Codable {
        /// The SCIM Connection object affected by this API call.
        public let connection: SCIMConnectionWithNextBearerToken
    }

    struct SCIMRotateCompleteResponseData: Codable {
        /// The SCIM Connection object affected by this API call.
        public let connection: SCIMConnection
    }

    struct SCIMRotateCancelResponseData: Codable {
        /// The SCIM Connection object affected by this API call.
        public let connection: SCIMConnection
    }
}
