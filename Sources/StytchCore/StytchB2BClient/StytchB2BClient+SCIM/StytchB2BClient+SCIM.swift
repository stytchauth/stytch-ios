import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with SCIM.
    static var scim: SCIM {
        .init(router: router.scopedRouter {
            $0.scim
        })
    }
}

public extension StytchB2BClient {
    struct SCIM {
        let router: NetworkingRouter<SCIMRoute>

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Creates a new SCIM connection.
        /// This method wraps the create-connection endpoint (https://stytch.com/docs/b2b/api/create-scim-connection).
        /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
        public func createConnection(parameters: CreateConnectionParameters) async throws -> SCIMCreateConnectionResponse {
            try await router.post(to: .createConnection, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        ///  Updates an existing SCIM connection.
        ///  This method wraps the update-connection endpoint (https://stytch.com/docs/b2b/api/update-scim-connection).
        ///  If attempting to modify the `scim_group_implicit_role_assignments` the caller must have the
        ///  `update.settings.implicit-roles` permission on the `stytch.organization` resource. For all other fields, the
        ///  caller must have the `update` permission on the `stytch.scim` resource. SCIM via the project's RBAC policy &
        ///  their role assignments.
        public func updateConnection(parameters: UpdateConnectionParameters) async throws -> SCIMUpdateConnectionResponse {
            try await router.put(to: .updateConnection(connectionId: parameters.connectionId), parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Deletes an existing SCIM connection.
        /// This method wraps the delete-connection endpoint (https://stytch.com/docs/b2b/api/delete-scim-connection).
        /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
        public func deleteConnection(connectionId: String) async throws -> SCIMDeleteConnectionResponse {
            try await router.delete(route: .deleteConnection(connectionId: connectionId))
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Gets the SCIM connection for an organization.
        /// This method wraps the get-connection endpoint (https://stytch.com/docs/b2b/api/get-scim-connection).
        /// The caller must have permission to view SCIM via the project's RBAC policy & their role assignments.
        public func getConnection() async throws -> SCIMGetConnectionResponse {
            try await router.get(route: .getConnection)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Gets all groups associated with an organization's SCIM connection.
        /// This method wraps the get-connection-groups endpoint (https://stytch.com/docs/b2b/api/get-scim-connection-groups).
        /// The caller must have permission to view SCIM via the project's RBAC policy & their role assignments.
        public func getConnectionGroups(parameters: GetConnectionGroupsParameters) async throws -> SCIMGetConnectionGroupsResponse {
            try await router.post(to: .getConnectionGroups, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Starts the SCIM bearer token rotation process.
        /// This method wraps the start-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-start).
        /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
        public func rotateStart(parameters: RotateParameters) async throws -> SCIMRotateStartResponse {
            try await router.post(to: .rotateStart, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Completes the SCIM bearer token rotate, removing the old bearer token from operation.
        /// This method wraps the complete-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-complete).
        /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
        public func rotateComplete(parameters: RotateParameters) async throws -> SCIMRotateCompleteResponse {
            try await router.post(to: .rotateComplete, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Cancels the SCIM bearer token rotate, removing the new bearer token issued.
        /// This method wraps the cancel-rotation endpoint (https://stytch.com/docs/b2b/api/scim-rotate-token-cancel).
        /// The caller must have permission to modify SCIM via the project's RBAC policy & their role assignments.
        public func rotateCancel(parameters: RotateParameters) async throws -> SCIMRotateCancelResponse {
            try await router.post(to: .rotateCancel, parameters: parameters)
        }
    }
}
