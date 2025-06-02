import Foundation
import StytchCore

extension StytchB2BUIClient {
    /*
       Here we are generating the ordering and which components will be displayed.
       We use the ProductComponent enum this because there is some complex logic here, and
       we want to be able to unit test.

       Rules we want to follow when generating the components:
       1. If we're displaying both email magic links or email otp and passwords, we need to display them together
       as a single wrapped component. The index of this wrapped component is equivalent to the first index of
       either email magic links, email otp, or passwords in the config products list.
       2. If both buttons and input are present, display a divider above and below the input component.
       Do not add a divider above if the input is the first component or below if it is the last.
       3. We want to display the components in the order that they are listed in the config.
     */
    static func productComponentsOrdering(
        validProducts: [StytchB2BUIClient.B2BProducts],
        configuration: StytchB2BUIClient.Configuration,
        hasSSOActiveConnections: Bool?
    ) -> [ProductComponent] {
        var productComponents = [ProductComponent]()
        for product in validProducts {
            switch product {
            case .emailMagicLinks, .emailOtp, .passwords:
                if configuration.supportsEmailAndPasswords == true {
                    productComponents.appendIfNotPresent(.emailAndPasswords)
                } else if configuration.supportsPasswordsWithoutEmail == true {
                    productComponents.appendIfNotPresent(.password)
                } else if configuration.supportsEmailWithoutPasswords == true {
                    productComponents.appendIfNotPresent(.email)
                }
            case .sso:
                switch configuration.computedAuthFlowType {
                case .discovery:
                    productComponents.appendIfNotPresent(.ssoButtons)
                case .organization:
                    if hasSSOActiveConnections == true {
                        productComponents.appendIfNotPresent(.ssoButtons)
                    }
                }
            case .oauth:
                productComponents.appendIfNotPresent(.oAuthButtons)
            }
        }

        productComponents = addDividers(to: productComponents)
        return productComponents
    }

    static func addDividers(to components: [ProductComponent]) -> [ProductComponent] {
        var updatedComponents: [ProductComponent] = []

        for (index, component) in components.enumerated() {
            // Add dividers above and below input types
            // Check if the current component is one of the target types
            let shouldAddDivider = component == .email || component == .emailAndPasswords || component == .password

            // Add a divider before the component if needed
            if shouldAddDivider, index > 0 {
                updatedComponents.append(.divider)
            }

            // Add the current component
            updatedComponents.append(component)

            // Add a divider after the component if needed
            if shouldAddDivider, index < components.count - 1 {
                updatedComponents.append(.divider)
            }
        }

        return updatedComponents
    }
}

extension StytchB2BUIClient {
    enum ProductComponent: String, Equatable {
        case email
        case emailAndPasswords
        case password
        case oAuthButtons
        case ssoButtons
        case divider
    }
}
