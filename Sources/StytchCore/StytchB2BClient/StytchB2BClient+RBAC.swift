import Foundation

public extension StytchB2BClient {
    /// The interface for interacting with rbac permissions.
    static var rbac: RBAC {
        .init()
    }
}

public extension StytchB2BClient {
    struct RBAC {
        @Dependency(\.localStorage) private var localStorage
        @Dependency(\.sessionManager) private var sessionManager
        @Dependency(\.memberSessionStorage) private var memberSessionStorage

        private var memberSessionRoles: [String] {
            memberSessionStorage.object?.roles ?? []
        }

        /// Determines whether the logged-in member is allowed to perform the specified action on the specified resource.
        /// Returns `true` if the member can perform the action, `false` otherwise.
        ///
        /// This method uses a locally-cached instance of the member and the configured RBAC policy.
        /// If the member is not logged in, or the RBAC policy has not been loaded, this method will always return false.
        /// If the resource or action provided are not valid for the configured RBAC policy, this method will return false.
        ///
        /// To check authorization using guaranteed-fresh data, use {@link isAuthorized}.
        /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
        public func isAuthorizedSync(resourceId: String, action: String) -> Bool {
            guard let rbacPolicy = localStorage.bootstrapData?.rbacPolicy else {
                return false
            }

            return rbacPolicy.callerIsAuthorized(
                memberRoles: memberSessionRoles,
                resourceId: resourceId,
                action: action
            )
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Determines whether the logged-in member is allowed to perform the specified action on the specified resource.
        /// Returns `true` if the member can perform the action, `false` otherwise.
        ///
        /// If the member is not logged in, this method will always return false.
        /// If the resource or action provided are not valid for the configured RBAC policy, this method will return false.
        ///
        /// To check authorization using cached data, use {@link isAuthorizedSync}.
        /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
        public func isAuthorized(resourceId: String, action: String) async throws -> Bool {
            try await StartupClient.bootstrap()
            return isAuthorizedSync(resourceId: resourceId, action: action)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Evaluates all permissions granted to the logged-in member.
        /// Returns a Map<RoleId, Map<Action, Boolean>> response indicating the member's permissions.
        /// Each boolean will be `true` if the member can perform the action, `false` otherwise.
        ///
        /// If the member is not logged in, all values will be false.
        ///
        /// Remember - authorization checks for sensitive actions should always occur on the backend as well.
        public func allPermissions() async throws -> [String: [String: Bool]] {
            try await StartupClient.bootstrap()

            guard let rbacPolicy = localStorage.bootstrapData?.rbacPolicy else {
                return [:]
            }

            return rbacPolicy.allPermissionsForCaller(memberRoles: memberSessionRoles)
        }
    }
}
