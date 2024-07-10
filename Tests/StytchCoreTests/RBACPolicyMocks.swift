import XCTest
@testable import StytchCore

extension RBACPolicy {
    static var mock: Self {
        let resources: [RBACPolicyResource] = [
            RBACPolicyResource(
                resourceId: "documents",
                description: "",
                actions: ["create", "read", "write", "delete"]
            ),
            RBACPolicyResource(
                resourceId: "images",
                description: "",
                actions: ["create", "read", "delete"]
            ),
            RBACPolicyResource(
                resourceId: "secrets",
                description: "",
                actions: ["read"]
            ),
        ]

        let roles: [RBACPolicyRole] = [
            RBACPolicyRole(
                roleId: "default",
                description: "",
                permissions: []
            ),
            RBACPolicyRole(
                roleId: "organization_admin",
                description: "",
                permissions:
                [
                    RBACPermission(
                        resourceId: "documents",
                        actions: ["*"]
                    ),
                    RBACPermission(
                        resourceId: "images",
                        actions: ["*"]
                    ),
                    RBACPermission(
                        resourceId: "secrets",
                        actions: ["*"]
                    ),
                ]
            ),
            RBACPolicyRole(
                roleId: "editor",
                description: "",
                permissions:
                [
                    RBACPermission(
                        resourceId: "documents",
                        actions: ["read", "write"]
                    ),
                    RBACPermission(
                        resourceId: "images",
                        actions: ["create", "read", "delete"]
                    ),
                ]
            ),
            RBACPolicyRole(
                roleId: "reader",
                description: "",
                permissions:
                [
                    RBACPermission(
                        resourceId: "documents",
                        actions: ["read"]
                    ),
                    RBACPermission(
                        resourceId: "images",
                        actions: ["read"]
                    ),
                ]
            ),
        ]

        return RBACPolicy(roles: roles, resources: resources)
    }

    static var mockWithoutDefaultRole: Self {
        RBACPolicy(
            roles: [
                RBACPolicyRole(
                    roleId: "organization_admin",
                    description: "",
                    permissions: [
                        RBACPermission(
                            resourceId: "documents",
                            actions: ["*"]
                        ),
                    ]
                ),
            ],
            resources: [
                RBACPolicyResource(
                    resourceId: "documents",
                    description: "",
                    actions: ["create", "read", "write", "delete", "admin-create"]
                ),
            ]
        )
    }
}
