import Foundation

public struct RBACPolicy: Codable {
    public let roles: [RBACPolicyRole]
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

    public func callerIsAuthorized(
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

    public func allPermissionsForCaller(memberRoles: [String]) -> [String: [String: Bool]] {
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

public struct RBACPermission: Codable {
    public let resourceId: String
    public let actions: [String]

    public func permission(resourceId: String, action: String) -> Bool {
        if self.resourceId == resourceId {
            return actions.contains(action) || actions.contains("*")
        } else {
            return false
        }
    }
}

public struct RBACPolicyRole: Codable {
    public let roleId: String
    public let description: String
    public let permissions: [RBACPermission]
}

public struct RBACPolicyResource: Codable {
    public let resourceId: String
    public let description: String
    public let actions: [String]
}
