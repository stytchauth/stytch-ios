import XCTest
@testable import StytchCore

final class B2BRBACTestCase: BaseTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testIsAuthorizedSync() {
        // Given we have loaded the bootstrap data and we have a member session
        Current.localStorage.bootstrapData = .mock
        Current.memberSessionStorage.update(.mock)

        // When we have verified that we have the expected permissions
        let isAuthorizedSync = StytchB2BClient.rbac.isAuthorizedSync(resourceId: "documents", action: "read")

        // Then the value is true
        XCTAssertTrue(isAuthorizedSync)
    }

    func testIsAuthorized() async throws {
        // Given we have loaded the bootstrap data and we have a member session
        // And we have verified that we have the expected permissions
        Current.localStorage.bootstrapData = .mock
        Current.memberSessionStorage.update(.mock)
        XCTAssertTrue(StytchB2BClient.rbac.isAuthorizedSync(resourceId: "documents", action: "read"))

        // This will confirm the results that we have loaded a new bootstrap response below
        let isAuthorizedFalse = StytchB2BClient.rbac.isAuthorizedSync(resourceId: "documents", action: "admin-create")
        XCTAssertFalse(isAuthorizedFalse)

        // When we check for isAuthorized by fetching a new bootstrap response
        Current.memberSessionStorage.update(.mockWithAdminRole)
        networkInterceptor.responses {
            BootstrapResponse(requestId: "1234", statusCode: 200, wrapped: .mockWithoutDefaultRBACRole)
        }

        // Then we can confirm that the new bootstrap data is loaded with new permissions
        let isAuthorized = try await StytchB2BClient.rbac.isAuthorized(resourceId: "documents", action: "admin-create")
        XCTAssertTrue(isAuthorized)
    }

    func testAllPermissions() async throws {
        // Give that we load the the first boot strap response and get the permissions
        Current.memberSessionStorage.update(.mock)
        networkInterceptor.responses {
            BootstrapResponse(requestId: "1234", statusCode: 200, wrapped: .mock)
        }
        let allPermissions1 = try await StytchB2BClient.rbac.allPermissions()

        // When we load a new boot strap response and get the new permissions
        Current.memberSessionStorage.update(.mockWithAdminRole)
        networkInterceptor.responses {
            BootstrapResponse(requestId: "1234", statusCode: 200, wrapped: .mockWithoutDefaultRBACRole)
        }
        let allPermissions2 = try await StytchB2BClient.rbac.allPermissions()

        // Then the permissions are not equal, proving we have 2 different permission sets
        XCTAssertTrue(allPermissions1 != allPermissions2)
    }
}

extension BootstrapResponseData {
    static var mock: Self {
        .init(
            disableSdkWatermark: false,
            cnameDomain: nil,
            emailDomains: [],
            captchaSettings: CaptchaSettings(enabled: false, siteKey: nil),
            pkceRequiredForEmailMagicLinks: false,
            pkceRequiredForPasswordResets: false,
            pkceRequiredForOauth: false,
            pkceRequiredForSso: false,
            slugPattern: nil,
            createOrganizationEnabled: false,
            dfpProtectedAuthEnabled: false,
            dfpProtectedAuthMode: nil,
            rbacPolicy: .mock,
            passwordConfig: nil,
            vertical: nil
        )
    }

    static var mockWithoutDefaultRBACRole: Self {
        .init(
            disableSdkWatermark: false,
            cnameDomain: nil,
            emailDomains: [],
            captchaSettings: CaptchaSettings(enabled: false, siteKey: nil),
            pkceRequiredForEmailMagicLinks: false,
            pkceRequiredForPasswordResets: false,
            pkceRequiredForOauth: false,
            pkceRequiredForSso: false,
            slugPattern: nil,
            createOrganizationEnabled: false,
            dfpProtectedAuthEnabled: false,
            dfpProtectedAuthMode: nil,
            rbacPolicy: .mockWithoutDefaultRole,
            passwordConfig: nil,
            vertical: nil
        )
    }
}
