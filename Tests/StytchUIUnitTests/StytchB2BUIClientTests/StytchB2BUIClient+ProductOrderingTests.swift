import XCTest
@testable import StytchCore
@testable import StytchUI

final class ProductOrderingTests: B2BBaseTestCase {
    func configuration(
        products: [StytchB2BUIClient.B2BProducts],
        authFlowType: StytchB2BUIClient.AuthFlowType
    ) -> StytchB2BUIClient.Configuration {
        .init(
            publicToken: "public-token",
            hostUrl: nil,
            products: products,
            authFlowType: authFlowType,
            sessionDurationMinutes: .defaultSessionDuration,
            emailMagicLinksOptions: nil,
            passwordOptions: nil,
            oauthProviders: [],
            emailOtpOptions: nil,
            directLoginForSingleMembershipOptions: nil,
            allowCreateOrganization: false,
            mfaProductOrder: nil,
            mfaProductInclude: nil,
            navigation: nil,
            theme: StytchTheme()
        )
    }

    func testHasBothEmailProductsInDiscovery() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks]
        let configuration = configuration(
            products: products,
            authFlowType: .discovery
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: false)
        XCTAssertTrue(productComponents.contains(.email))
        XCTAssertTrue(productComponents.count == 1, "\(productComponents)")
    }

    func testHasProductsNotValidInDiscovery() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .passwords, .sso]
        let configuration = configuration(
            products: products,
            authFlowType: .discovery
        )

        // Currently in Discovery there are no passwords
        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: false)
        XCTAssertTrue(productComponents.contains(.email))
        XCTAssertTrue(productComponents.count == 1, "\(productComponents)")
    }

    func testHasBothEmailProductsAndPasswordsInOrganization() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .passwords]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: false)
        XCTAssertTrue(productComponents.contains(.emailAndPasswords))
        XCTAssertTrue(productComponents.count == 1, "\(productComponents)")
    }

    func testHasAllProductsInOrganization() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .passwords, .sso, .oauth]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertTrue(productComponents.contains(.emailAndPasswords))
        XCTAssertTrue(productComponents.contains(.ssoButtons))
        XCTAssertTrue(productComponents.contains(.oAuthButtons))
        XCTAssertTrue(productComponents.contains(.divider))
        XCTAssertTrue(productComponents.count == 4, "\(productComponents)")
    }

    func testHasPasswordsWithoutEmailInOrganization() {
        let products: [StytchB2BUIClient.B2BProducts] = [.passwords, .sso, .oauth]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertTrue(productComponents.contains(.password))
        XCTAssertTrue(productComponents.contains(.ssoButtons))
        XCTAssertTrue(productComponents.contains(.oAuthButtons))
        XCTAssertTrue(productComponents.contains(.divider))
        XCTAssertTrue(productComponents.count == 4, "\(productComponents)")
    }
}
