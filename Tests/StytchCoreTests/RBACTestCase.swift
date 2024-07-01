import XCTest
@testable import StytchCore

// swiftlint:disable function_body_length
// swiftlint:disable type_name

final class RBACPolicyCallerIsAuthorizedTestCase: BaseTestCase {
    struct TestCase {
        let name: String
        let subjectRoles: [String]
        let resourceId: String
        let action: String
        let callerIsAuthorized: Bool
    }

    func confirmTestCase(_ testCase: TestCase) {
        let actual = RBACPolicy.mock.callerIsAuthorized(
            memberRoles: testCase.subjectRoles,
            resourceId: testCase.resourceId,
            action: testCase.action
        )
        XCTAssertTrue(actual == testCase.callerIsAuthorized)
    }

    func testCallerIsAuthorized() {
        confirmTestCase(
            TestCase(
                name: "Success case - exact match",
                subjectRoles: ["default", "reader"],
                resourceId: "documents",
                action: "read",
                callerIsAuthorized: true
            )
        )

        confirmTestCase(
            TestCase(
                name: "Success case - multiple matches",
                subjectRoles: ["default", "reader", "editor", "organization_admin"],
                resourceId: "documents",
                action: "read",
                callerIsAuthorized: true
            )
        )

        confirmTestCase(
            TestCase(
                name: "Success case - multiple matches II",
                subjectRoles: ["default", "reader", "editor", "organization_admin"],
                resourceId: "images",
                action: "create",
                callerIsAuthorized: true
            )
        )

        confirmTestCase(
            TestCase(
                name: "Failure case - unauthorized action",
                subjectRoles: ["default", "reader"],
                resourceId: "images",
                action: "create",
                callerIsAuthorized: false
            )
        )

        confirmTestCase(
            TestCase(
                name: "Failure case - unauthorized resource",
                subjectRoles: ["default", "reader"],
                resourceId: "secrets",
                action: "read",
                callerIsAuthorized: false
            )
        )

        confirmTestCase(
            TestCase(
                name: "Failure case - invalid action",
                subjectRoles: ["default", "editor"],
                resourceId: "documents",
                action: "burn",
                callerIsAuthorized: false
            )
        )

        confirmTestCase(
            TestCase(
                name: "Failure case - invalid resource",
                subjectRoles: ["default", "editor"],
                resourceId: "squirrels",
                action: "write",
                callerIsAuthorized: false
            )
        )

        confirmTestCase(
            TestCase(
                name: "Failure case - invalid role",
                subjectRoles: ["default", "wizard"],
                resourceId: "documents",
                action: "write",
                callerIsAuthorized: false
            )
        )
    }
}

final class RBACPolicyAllPermissionsForCallerTestCase: BaseTestCase {
    struct TestCase {
        let name: String
        let subjectRoles: [String]
        let expectedPermissions: [String: [String: Bool]]
    }

    func confirmTestCase(_ testCase: TestCase) {
        let actual = RBACPolicy.mock.allPermissionsForCaller(memberRoles: testCase.subjectRoles)
        XCTAssertTrue(actual == testCase.expectedPermissions)
    }

    func testAllPermissionsForCaller() {
        confirmTestCase(
            TestCase(
                name: "Returns all false for a caller with no permissions",
                subjectRoles: ["default"],
                expectedPermissions: [
                    "documents": [
                        "create": false,
                        "read": false,
                        "write": false,
                        "delete": false,
                    ],
                    "images": [
                        "create": false,
                        "read": false,
                        "delete": false,
                    ],
                    "secrets": [
                        "read": false,
                    ],
                ]
            )
        )

        confirmTestCase(
            TestCase(
                name: "Returns a mix for a caller with some permissions",
                subjectRoles: ["reader"],
                expectedPermissions: [
                    "documents": [
                        "create": false,
                        "read": true,
                        "write": false,
                        "delete": false,
                    ],
                    "images": [
                        "create": false,
                        "read": true,
                        "delete": false,
                    ],
                    "secrets": [
                        "read": false,
                    ],
                ]
            )
        )

        confirmTestCase(
            TestCase(
                name: "Returns the union for a caller with multiple roles",
                subjectRoles: ["reader", "editor"],
                expectedPermissions: [
                    "documents": [
                        "create": false,
                        "read": true,
                        "write": true,
                        "delete": false,
                    ],
                    "images": [
                        "create": true,
                        "read": true,
                        "delete": true,
                    ],
                    "secrets": [
                        "read": false,
                    ],
                ]
            )
        )

        confirmTestCase(
            TestCase(
                name: "Returns all true for a caller with all permissions",
                subjectRoles: ["organization_admin"],
                expectedPermissions: [
                    "documents": [
                        "create": true,
                        "read": true,
                        "write": true,
                        "delete": true,
                    ],
                    "images": [
                        "create": true,
                        "read": true,
                        "delete": true,
                    ],
                    "secrets": [
                        "read": true,
                    ],
                ]
            )
        )
    }
}
