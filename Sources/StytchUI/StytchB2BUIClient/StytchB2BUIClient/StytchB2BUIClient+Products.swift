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

extension StytchB2BUIClient {
    /*
       Here we are generating the ordering and which components will be displayed.
       We use the ProductComponent enum this because there is some complex logic here, and
       we want to be able to unit test.

       Rules we want to follow when generating the components:
       1. If we're displaying both email magic links and passwords, we need to display them together
       as a single wrapped component. The index of this wrapped component is equivalent to the first index of
       either email magic links or passwords in the config products list.
       2. If we have both buttons and input, we want to display a divider between the last 2 elements.
       3. Some components have both a discovery and a non-discovery version. We want to display the correct version
       based on the flow type (found in state).
       4. We want to display the components in the order that they are listed in the config.

       This function should be considered the source of truth for which components to render
       and what order to render them in as of 6/21/23.
     */
    static func productComponentsOrdering(
        configuration: StytchB2BUIClient.Configuration,
        organization: Organization
    ) -> [ProductComponent] {
        let configurationProducts = configuration.products
        let authFlowType = configuration.authFlowType
        let displayEmlAndPasswordsTogether = configurationProducts.contains(.emailMagicLinks) && configurationProducts.contains(.passwords)

        var productComponents = [ProductComponent]()
        for product in configurationProducts {
            switch product {
            case .emailMagicLinks:
                if displayEmlAndPasswordsTogether == false {
                    if case .organization = authFlowType {
                        productComponents.append(.magicLinkEmailForm)
                    } else {
                        productComponents.append(.magicLinkEmailDiscoveryForm)
                    }
                }
            case .emailOtp:
                break
            case .sso:
                // We only need to render a component if we have a valid SSO connection
                let isSsoValid = (organization.ssoActiveConnections?.count ?? 0) > 0
                if case .organization = authFlowType, isSsoValid {
                    productComponents.append(.ssoButtons)
                }
            case .passwords:
                if displayEmlAndPasswordsTogether == false {
                    productComponents.append(.passwordsEmailForm)
                }
            case .oauth:
                productComponents.append(.oAuthButtons)
            }
        }

        // If we're displaying both email magic links and passwords, we need to display them together
        if displayEmlAndPasswordsTogether {
            // Get the first index of either email magic links or passwords
            let passwordIndex = configurationProducts.firstIndex(of: .passwords) ?? Int.max
            let emlIndex = configurationProducts.firstIndex(of: .emailMagicLinks) ?? Int.max
            let firstProductIndex = min(passwordIndex, emlIndex)

            // Determine the combined component
            let combinedComponent: ProductComponent
            if case .organization = authFlowType {
                combinedComponent = .passwordEMLCombined
            } else {
                combinedComponent = .magicLinkEmailDiscoveryForm
            }

            // Insert combined component into the first index of either email magic links or passwords
            productComponents.insert(combinedComponent, at: firstProductIndex)
        }

        // If we have both buttons and input, we want to display a divider between the last 2 elements
        let hasButtons = productComponents.contains(.oAuthButtons) || productComponents.contains(.ssoButtons)
        let hasInput = configurationProducts.contains(.emailMagicLinks) || configurationProducts.contains(.passwords)
        let showDivider = hasButtons && hasInput

        if productComponents.count > 1, showDivider {
            productComponents.insert(.divider, at: productComponents.count - 1)
        }

        return productComponents
    }
}

extension StytchB2BUIClient {
    enum ProductComponent: String {
        case magicLinkEmailForm
        case magicLinkEmailDiscoveryForm
        case oAuthButtons
        case ssoButtons
        case passwordsEmailForm
        case passwordEMLCombined
        case divider
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
