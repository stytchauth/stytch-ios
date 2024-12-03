import Foundation
import StytchCore

// swiftlint:disable cyclomatic_complexity

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
        validProducts: [StytchB2BUIClient.B2BProducts],
        configuration: StytchB2BUIClient.Configuration,
        hasSSOActiveConnections: Bool?
    ) -> [ProductComponent] {
        var productComponents = [ProductComponent]()
        for product in validProducts {
            switch product {
            case .emailMagicLinks:
                if case .discovery = configuration.authFlowType {
                    productComponents.append(.emailMagicLink)
                } else if configuration.supportsEmailMagicLinksAndPasswords == true {
                    productComponents.append(.emailMagicLinkAndPasswords)
                } else {
                    productComponents.append(.emailMagicLink)
                }
            case .emailOtp:
                break
            case .sso:
                if case .organization = configuration.authFlowType, hasSSOActiveConnections == true {
                    productComponents.append(.ssoButtons)
                }
            case .passwords:
                if case .organization = configuration.authFlowType {
                    if configuration.supportsEmailMagicLinksAndPasswords == true {
                        productComponents.append(.emailMagicLinkAndPasswords)
                    } else {
                        productComponents.append(.password)
                    }
                }
            case .oauth:
                productComponents.append(.oAuthButtons)
            }
        }

        // If we have both buttons and input, we want to display a divider between the last 2 elements
        let hasButtons = productComponents.contains(.oAuthButtons) || productComponents.contains(.ssoButtons)
        let showDivider = hasButtons && (configuration.supportsEmailMagicLinks || configuration.supportsPasswords)

        if productComponents.count > 1, showDivider {
            productComponents.insert(.divider, at: productComponents.count - 1)
        }

        return productComponents
    }
}

extension StytchB2BUIClient {
    enum ProductComponent: String {
        case emailMagicLink
        case emailMagicLinkAndPasswords
        case password
        case oAuthButtons
        case ssoButtons
        case divider
    }
}
