import XCTest
@testable import StytchCore
@testable import StytchUI

final class ProductOrderingTests: B2BBaseTestCase {
    func configuration(
        products: [StytchB2BUIClient.B2BProducts],
        authFlowType: StytchB2BUIClient.AuthFlowType
    ) -> StytchB2BUIClient.Configuration {
        .init(
            stytchClientConfiguration: .init(publicToken: "publicToken", defaultSessionDuration: 5),
            products: products,
            authFlowType: authFlowType,
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
        XCTAssertEqual(productComponents, [.email])
    }

    func testHasBothEmailProductsAndPasswordsInOrganization() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .passwords]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: false)
        XCTAssertEqual(productComponents, [.emailAndPasswords])
    }

    func testHasBothEmailProductsAndPasswordsInDiscovery() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .passwords]
        let configuration = configuration(
            products: products,
            authFlowType: .discovery
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: false)
        XCTAssertEqual(productComponents, [.emailAndPasswords])
    }

    func testHasAllProductsInOrganization() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .passwords, .sso, .oauth]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertEqual(productComponents, [.emailAndPasswords, .divider, .ssoButtons, .oAuthButtons])
    }

    func testHasPasswordsWithoutEmailInOrganization() {
        let products: [StytchB2BUIClient.B2BProducts] = [.passwords, .sso, .oauth]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertEqual(productComponents, [.password, .divider, .ssoButtons, .oAuthButtons])
    }

    func testRemovesDuplicateProducts() {
        let products: [StytchB2BUIClient.B2BProducts] = [.emailOtp, .emailMagicLinks, .emailOtp, .passwords, .passwords, .passwords, .sso, .oauth, .sso, .oauth]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )
        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertEqual(productComponents, [.emailAndPasswords, .divider, .ssoButtons, .oAuthButtons])
    }

    func testSSOButtonFirst() {
        let products: [StytchB2BUIClient.B2BProducts] = [.sso, .oauth, .emailOtp, .emailMagicLinks, .passwords]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertEqual(productComponents, [.ssoButtons, .oAuthButtons, .divider, .emailAndPasswords])
    }

    func testOAuthButtonFirstSSOButtonsLast() {
        let products: [StytchB2BUIClient.B2BProducts] = [.oauth, .emailOtp, .emailMagicLinks, .passwords, .sso]
        let configuration = configuration(
            products: products,
            authFlowType: .organization(slug: "123")
        )

        let productComponents = StytchB2BUIClient.productComponentsOrdering(validProducts: products, configuration: configuration, hasSSOActiveConnections: true)
        XCTAssertEqual(productComponents, [.oAuthButtons, .divider, .emailAndPasswords, .divider, .ssoButtons])
    }
}
