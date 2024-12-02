import Foundation
import StytchCore

extension StytchB2BUIClient {
    static func validProducts(
        organizationAllowedAuthMethods: [StytchB2BClient.AllowedAuthMethods]?,
        organizationAuthMethods: StytchB2BClient.AuthMethods?,
        primaryRequired: PrimaryRequired?,
        configuration: StytchB2BUIClient.Configuration
    ) -> [StytchB2BUIClient.B2BProducts] {
        // If primaryRequired supplies a valid list of allowedAuthMethods we must use it.
        if let allowedAuthMethods = primaryRequired?.allowedAuthMethods, allowedAuthMethods.isEmpty == false {
            let intersection = allowedB2BProducts(allowedAuthMethods: allowedAuthMethods, b2bProducts: configuration.products)

            // If the intersection is empty and the organization allows all auth methods we will show the user magic links.
            // if there are restrictions on the auth methods allowed we will show the auth methods specified in primaryRequired?.allowedAuthMethods.
            if intersection.isEmpty {
                if organizationAuthMethods == .allAllowed {
                    return [.emailMagicLinks]
                } else {
                    return allowedAuthMethods.compactMap { authMethod in
                        authMethod.correspondingB2BProduct
                    }
                }
            } else {
                return intersection
            }
        }

        // If primaryRequired?.allowedAuthMethods is empty the we can simply take the intersection of the
        // organization.allowedAuthMethods and the and the products supplied by the application developer.
        // If that returns an empty array we allow that to be shown assuming user error and a misconfigured UI with their dashboard set up.
        if let allowedAuthMethods = organizationAllowedAuthMethods, organizationAuthMethods == .restricted {
            return allowedB2BProducts(allowedAuthMethods: allowedAuthMethods, b2bProducts: configuration.products)
        } else {
            return configuration.products
        }
    }

    // We then take the intersection of those allowedAuthMethods and the products supplied by the application developer.
    // Which only returns the B2BProducts that were present in allowedAuthMethods.
    static func allowedB2BProducts(
        allowedAuthMethods: [StytchB2BClient.AllowedAuthMethods],
        b2bProducts: [StytchB2BUIClient.B2BProducts]
    ) -> [StytchB2BUIClient.B2BProducts] {
        // Map AllowedAuthMethods to corresponding B2BProducts
        let allowedB2BProducts: [StytchB2BUIClient.B2BProducts] = allowedAuthMethods.compactMap { authMethod in
            authMethod.correspondingB2BProduct
        }

        // Filter B2BProducts based on the allowed list
        return b2bProducts.filter { allowedB2BProducts.contains($0) }
    }
}

extension StytchB2BClient.AllowedAuthMethods {
    /// Maps an `AllowedAuthMethods` value to its corresponding `B2BProducts` value.
    var correspondingB2BProduct: StytchB2BUIClient.B2BProducts? {
        switch self {
        case .sso:
            return .sso
        case .magicLink:
            return .emailMagicLinks
        case .password:
            return .passwords
        case .googleOAuth, .microsoftOAuth, .hubspotOAuth, .slackOAuth, .githubOAuth:
            return .oauth
        case .emailOtp:
            return .emailOtp
        }
    }
}
