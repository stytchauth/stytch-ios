import Foundation

public extension StytchB2BClient.SCIM {
    struct CreateConnectionParameters: Codable {
        let displayName: String?
        let identityProvider: String?

        /// - Parameters:
        ///   - displayName: A human-readable display name for the connection.
        ///   - identityProvider: The identity provider of this connection.
        public init(
            displayName: String? = nil,
            identityProvider: String? = nil
        ) {
            self.displayName = displayName
            self.identityProvider = identityProvider
        }
    }

    struct UpdateConnectionParameters: Codable {
        let connectionId: String
        let displayName: String?
        let identityProvider: String?
        let scimGroupImplicitRoleAssignments: [SCIMGroupImplicitRoleAssignment]?

        /// - Parameters:
        ///   - connectionId: Globally unique UUID that identifies a specific SCIM Connection.
        ///   - displayName: A human-readable display name for the connection.
        ///   - identityProvider: The identity provider of this connection.
        ///   - scimGroupImplicitRoleAssignments: An array of implicit role assignments granted to members in this organization who are created via this SCIM connection and belong to the specified group. Before adding any group implicit role assignments, you must first provision groups from your IdP into Stytch
        public init(
            connectionId: String,
            displayName: String? = nil,
            identityProvider: String? = nil,
            scimGroupImplicitRoleAssignments: [SCIMGroupImplicitRoleAssignment]? = nil
        ) {
            self.connectionId = connectionId
            self.displayName = displayName
            self.identityProvider = identityProvider
            self.scimGroupImplicitRoleAssignments = scimGroupImplicitRoleAssignments
        }
    }

    struct GetConnectionGroupsParameters: Codable {
        let limit: Int?
        let cursor: String?

        /// - Parameters:
        ///   - limit: The maximum number of groups that should be returned by the API.
        ///   - cursor: The cursor to use to indicate where to start group results.
        public init(limit: Int? = nil, cursor: String? = nil) {
            self.limit = limit
            self.cursor = cursor
        }
    }

    struct RotateParameters: Codable {
        let connectionId: String

        /// - Parameter connectionId: Globally unique UUID that identifies a specific SCIM Connection.
        public init(connectionId: String) {
            self.connectionId = connectionId
        }
    }
}
