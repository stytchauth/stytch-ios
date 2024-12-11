import XCTest
@testable import StytchCore
@testable import StytchUI

final class ValidProductsTests: B2BBaseTestCase {
    let allAllowedAuthMethods: [StytchB2BClient.AllowedAuthMethods] = [
        .sso,
        .magicLink,
        .password,
        .googleOAuth,
        .microsoftOAuth,
        .hubspotOAuth,
        .slackOAuth,
        .githubOAuth,
        .emailOtp,
    ]

    let allB2BProducts: [StytchB2BUIClient.B2BProducts] = [
        .emailMagicLinks,
        .emailOtp,
        .sso,
        .passwords,
        .oauth,
    ]

    func testValidProducts() {
        var validProducts: [StytchB2BUIClient.B2BProducts] = []

        validProducts = StytchB2BUIClient.validProducts(
            organizationAllowedAuthMethods: [],
            organizationAuthMethods: .allAllowed,
            primaryRequired: nil,
            configurationProducts: [.emailMagicLinks],
            oauthProviders: []
        )
        XCTAssertEqual(validProducts, [.emailMagicLinks])
    }

    func testValidProductsRestrictedAuthMethods() {
        var validProducts: [StytchB2BUIClient.B2BProducts] = []

        validProducts = StytchB2BUIClient.validProducts(
            organizationAllowedAuthMethods: [.magicLink, .password, .sso],
            organizationAuthMethods: .restricted,
            primaryRequired: nil,
            configurationProducts: [.emailMagicLinks, .sso],
            oauthProviders: []
        )
        XCTAssertEqual(validProducts, [.emailMagicLinks, .sso])
    }

    func testValidProductsRestrictedAuthMethodsMismatchedOauthProviders() {
        var validProducts: [StytchB2BUIClient.B2BProducts] = []

        validProducts = StytchB2BUIClient.validProducts(
            organizationAllowedAuthMethods: [.magicLink, .password, .sso, .githubOAuth],
            organizationAuthMethods: .restricted,
            primaryRequired: nil,
            configurationProducts: [.emailMagicLinks, .sso, .oauth],
            oauthProviders: [.init(provider: .google)]
        )
        // Oauth should be absent since .googleOAuth was not one of the organizationAllowedAuthMethods
        XCTAssertEqual(validProducts, [.emailMagicLinks, .sso])
    }

    func testValidProductsRestrictedAuthMethodsMatchingOauthProviders() {
        var validProducts: [StytchB2BUIClient.B2BProducts] = []

        validProducts = StytchB2BUIClient.validProducts(
            organizationAllowedAuthMethods: [.magicLink, .password, .sso, .googleOAuth],
            organizationAuthMethods: .restricted,
            primaryRequired: nil,
            configurationProducts: [.emailMagicLinks, .sso, .oauth],
            oauthProviders: [.init(provider: .google)]
        )
        // Oauth should be present since .googleOAuth is one of the organizationAllowedAuthMethods
        XCTAssertEqual(validProducts, [.emailMagicLinks, .sso, .oauth])
    }

    func testAllowedB2BProducts() {
        var allowedB2BProducts: [StytchB2BUIClient.B2BProducts] = []

        allowedB2BProducts = StytchB2BUIClient.allowedB2BProducts(
            allowedAuthMethods: [.magicLink, .password],
            configurationProducts: [.passwords],
            oauthProviders: []
        )
        XCTAssertEqual(allowedB2BProducts, [.passwords])

        allowedB2BProducts = StytchB2BUIClient.allowedB2BProducts(
            allowedAuthMethods: [.magicLink, .password, .googleOAuth],
            configurationProducts: [.passwords, .oauth],
            oauthProviders: [.init(provider: .google)]
        )
        XCTAssertEqual(allowedB2BProducts, [.passwords, .oauth])
    }

    func testIsValidOAuthConfiguration() {
        XCTAssertTrue(StytchB2BUIClient.isValidOAuthConfiguration(allowedAuthMethods: [.googleOAuth], oauthProviders: [.init(provider: .google)]), "")
        XCTAssertTrue(StytchB2BUIClient.isValidOAuthConfiguration(allowedAuthMethods: [.googleOAuth, .hubspotOAuth], oauthProviders: [.init(provider: .google)]), "")

        XCTAssertFalse(StytchB2BUIClient.isValidOAuthConfiguration(allowedAuthMethods: [.hubspotOAuth], oauthProviders: [.init(provider: .google)]), "")
        XCTAssertFalse(StytchB2BUIClient.isValidOAuthConfiguration(allowedAuthMethods: [.hubspotOAuth], oauthProviders: []), "")
        XCTAssertFalse(StytchB2BUIClient.isValidOAuthConfiguration(allowedAuthMethods: [.magicLink, .password], oauthProviders: [.init(provider: .google)]), "")
    }

    func testIsAllowedOAuthProvider() {
        XCTAssertTrue(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.googleOAuth], oauthProviderOptions: .init(provider: .google)), "")
        XCTAssertTrue(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.microsoftOAuth], oauthProviderOptions: .init(provider: .microsoft)), "")
        XCTAssertTrue(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.hubspotOAuth], oauthProviderOptions: .init(provider: .hubspot)), "")
        XCTAssertTrue(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.slackOAuth], oauthProviderOptions: .init(provider: .slack)), "")
        XCTAssertTrue(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.githubOAuth], oauthProviderOptions: .init(provider: .github)), "")

        XCTAssertFalse(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.googleOAuth], oauthProviderOptions: .init(provider: .github)), "")
        XCTAssertFalse(StytchB2BUIClient.isAllowedOAuthProvider(allowedAuthMethods: [.magicLink, .password], oauthProviderOptions: .init(provider: .github)), "")
    }
}
