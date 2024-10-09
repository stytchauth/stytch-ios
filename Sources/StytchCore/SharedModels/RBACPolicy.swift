import Foundation

/// The RBAC Policy document that contains all defined Roles and Resources – which are managed in the Dashboard (https://stytch.com/dashboard/rbac).
/// Read more about these entities and how they work in our RBAC overview (https://stytch.com/docs/b2b/guides/rbac/overview).
public struct RBACPolicy: Codable {
    /// An array of Role objects.
    public let roles: [RBACPolicyRole]
    /// An array of Resource objects.
    public let resources: [RBACPolicyResource]

    private var rolesByID: [String: RBACPolicyRole] {
        var rolesByID = [String: RBACPolicyRole]()
        roles.forEach {
            rolesByID[$0.roleId] = $0
        }
        return rolesByID
    }

    private func permissions(memberRoles: [String]) -> [RBACPermission]? {
        memberRoles
            .compactMap {
                rolesByID[$0]
            }
            .flatMap(\.permissions)
    }

    internal func callerIsAuthorized(
        memberRoles: [String],
        resourceId: String,
        action: String
    ) -> Bool {
        guard let permissions = permissions(memberRoles: memberRoles) else {
            return false
        }

        let permission = permissions.first { permission in
            permission.permission(resourceId: resourceId, action: action)
        }

        return permission != nil
    }

    internal func allPermissionsForCaller(memberRoles: [String]) -> [String: [String: Bool]] {
        var allPermissions = [String: [String: Bool]]()

        for resource in resources {
            var actionsDictionary = [String: Bool]()
            for action in resource.actions {
                actionsDictionary[action] = callerIsAuthorized(memberRoles: memberRoles, resourceId: resource.resourceId, action: action)
            }
            allPermissions[resource.resourceId] = actionsDictionary
        }

        return allPermissions
    }
}

/// A list of permissions that link a Resource to a list of actions.
public struct RBACPermission: Codable {
    /// A unique identifier of the RBAC Resource, provided by the developer and intended to be human-readable.
    /// A resource_id is not allowed to start with stytch, which is a special prefix used for Stytch default Resources with reserved resource_ids.
    /// These include: stytch.organization, stytch.member, stytch.sso, stytch.self
    /// Check out the guide on Stytch default Resources for a more detailed explanation (https://stytch.com/docs/b2b/guides/rbac/stytch-default).
    public let resourceId: String
    /// A list of permitted actions the Role is authorized to take with the provided Resource.
    /// You can use * as a wildcard to grant a Role permission to use all possible actions related to the Resource.
    public let actions: [String]

    func permission(resourceId: String, action: String) -> Bool {
        if self.resourceId == resourceId {
            return actions.contains(action) || actions.contains("*")
        } else {
            return false
        }
    }
}

/// A Role is a named collection of permissions that links actions to a Resource.
/// Roles are assigned to Members, either explicitly by direct assignment or implicitly by matching attributes or conditions, which grants them permissions.
/// Role assignment can be programmatically managed through certain Stytch API endpoints.
/// Refer to this guide for details on controls for delegating Roles to Members (https://stytch.com/docs/b2b/guides/rbac/role-assignment).
/// All Roles are stored in your Project's RBAC Policy. You can create, manage, and assign Roles in the Dashboard (https://stytch.com/dashboard).
/// Check out the RBAC overview to learn more about Stytch's RBAC permissioning model (https://stytch.com/docs/b2b/guides/rbac/overview).
public struct RBACPolicyRole: Codable {
    /// The unique identifier of the RBAC Role, provided by the developer and intended to be human-readable.
    /// Reserved role_ids that are predefined by Stytch include: stytch_member, stytch_admin
    /// Check out the guide on Stytch default Roles for a more detailed explanation (https://stytch.com/docs/b2b/guides/rbac/stytch-default).
    public let roleId: String
    /// The description of the RBAC Role.
    public let description: String
    /// A list of permissions that link a Resource to a list of actions.
    public let permissions: [RBACPermission]
}

/// A Resource is an entity with an associated list of actions.
/// The actions list enumerates all the valid operations that can be performed upon the Resource.
/// All Resources are stored in your Project's RBAC Policy. You can create and manage Resources in the Dashboard (https://stytch.com/dashboard).
/// Check out the RBAC overview to learn more about Stytch's RBAC permissioning model (https://stytch.com/docs/b2b/guides/rbac/overview).
public struct RBACPolicyResource: Codable {
    /// A unique identifier of the RBAC Resource, provided by the developer and intended to be human-readable.
    /// A resource_id is not allowed to start with stytch, which is a special prefix used for Stytch default
    /// Resources with reserved resource_ids. These include: stytch.organization, stytch.member, stytch.sso, stytch.self
    /// Check out the guide on Stytch default Resources for a more detailed explanation (https://stytch.com/docs/b2b/guides/rbac/stytch-default).
    public let resourceId: String
    /// The description of the RBAC Role.
    public let description: String
    /// A list of permitted actions the Role is authorized to take with the provided Resource.
    /// You can use * as a wildcard to grant a Role permission to use all possible actions related to the Resource.
    public let actions: [String]
}
