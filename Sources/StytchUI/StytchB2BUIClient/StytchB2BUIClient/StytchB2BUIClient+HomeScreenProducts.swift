import Foundation
import StytchCore

extension StytchB2BUIClient {
    static func productsForHomeScreen(
        organization: Organization,
        primaryRequired: PrimaryRequired?,
        configuration: StytchB2BUIClient.Configuration
    ) -> [StytchB2BUIClient.B2BProducts] {
        //
        if let allowedAuthMethods = primaryRequired?.allowedAuthMethods {
            //
            let intersection = allowedB2BProducts(allowedAuthMethods: allowedAuthMethods, b2bProducts: configuration.products)

            //
            if intersection.isEmpty {
                if organization.authMethods == .allAllowed {
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

        //
        if let allowedAuthMethods = organization.allowedAuthMethods, organization.authMethods == .restricted {
            return allowedB2BProducts(allowedAuthMethods: allowedAuthMethods, b2bProducts: configuration.products)
        } else {
            return configuration.products
        }
    }

    //
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
