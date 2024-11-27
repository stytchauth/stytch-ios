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
            let intersection = allowedAuthMethods.allowedB2BProducts(from: configuration.products)

            //
            if intersection.isEmpty {
                if organization.authMethods == .allAllowed {
                    // Show magic links, try to the find the one with the options.
                    let magiclinkOptions = [StytchB2BClient.AllowedAuthMethods.magicLink].allowedB2BProducts(from: configuration.products)
                    if !magiclinkOptions.isEmpty {
                        return magiclinkOptions
                    } else {
                        return [.emailMagicLinks(emailMagicLinksOptions: nil)]
                    }
                } else {
                    // Show all the allowedAuthMethods
                    return allowedAuthMethods.allowedB2BProducts(from: [
                        .emailMagicLinks(emailMagicLinksOptions: nil),
                        .emailOtp(emailOtpOptions: nil),
                        .oauth(oauthProviders: []),
                        .sso,
                        .passwords(passwordOptions: nil),
                    ])
                }
            } else {
                return intersection
            }
        }

        //
        if let allowedAuthMethods = organization.allowedAuthMethods, organization.authMethods == .restricted {
            return allowedAuthMethods.allowedB2BProducts(from: configuration.products)
        } else {
            return configuration.products
        }
    }
}

extension StytchB2BClient.AllowedAuthMethods {
    /// Maps an `AllowedAuthMethods` value to its corresponding `B2BProducts` value.
    var correspondingB2BProduct: StytchB2BUIClient.B2BProducts? {
        switch self {
        case .sso:
            return .sso
        case .magicLink:
            return .emailMagicLinks(emailMagicLinksOptions: nil)
        case .password:
            return .passwords(passwordOptions: nil)
        case .googleOAuth, .microsoftOAuth, .hubspotOAuth, .slackOAuth, .githubOAuth:
            return .oauth(oauthProviders: [])
        case .emailOtp:
            return .emailOtp(emailOtpOptions: nil)
        }
    }
}

extension Array where Element == StytchB2BClient.AllowedAuthMethods {
    func allowedB2BProducts(from b2bProducts: [StytchB2BUIClient.B2BProducts]) -> [StytchB2BUIClient.B2BProducts] {
        // Iterate over `self` (AllowedAuthMethods array) and match with the provided B2B products
        compactMap { authMethod in
            authMethod.correspondingB2BProduct
        }.flatMap { allowedProduct in
            b2bProducts.filter { product in
                product == allowedProduct
            }
        }
    }
}
