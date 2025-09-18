import StytchCore
import UIKit

extension BaseViewController {
    func startDiscoveryFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
        Task { @MainActor in
            let discoveredOrganizations = DiscoveryManager.discoveredOrganizations

            if discoveredOrganizations.isEmpty, configuration.allowsDirectCreateOrganizationIfNoneExist == true {
                createOrganization()
            } else if let singleDiscoveredOrganization = discoveredOrganizations.shouldAllowDirectLoginToOrganization(configuration.directLoginForSingleMembershipOptions) {
                selectDiscoveredOrganization(configuration: configuration, discoveredOrganization: singleDiscoveredOrganization)
            } else {
                let viewController: UIViewController
                if DiscoveryManager.discoveredOrganizations.isEmpty {
                    if configuration.allowsUserCreateOrganizations == true {
                        viewController = CreateOrganizationViewController(state: .init(configuration: configuration))
                    } else {
                        viewController = NoDiscoveredOrganizationsViewController(state: .init(configuration: configuration))
                    }
                } else {
                    viewController = DiscoveredOrganizationsViewController(state: .init(configuration: configuration), discoveredOrganizations: DiscoveryManager.discoveredOrganizations)
                }

                // Reset the view controller stack to include only the home view controller and one of the discovery view controllers.
                // This ensures that if the user navigates back, they must restart the flow from the beginning.
                if let homeViewController = navigationController?.viewControllers.first {
                    navigationController?.setViewControllers([homeViewController, viewController], animated: true)
                }
            }
        }
    }

    func createOrganization() {
        Task {
            StytchB2BUIClient.startLoading()
            do {
                try await AuthenticationOperations.createOrganization()
                StytchB2BUIClient.stopLoading()
            } catch {
                StytchB2BUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }

    func selectDiscoveredOrganization(configuration: StytchB2BUIClient.Configuration, discoveredOrganization: StytchB2BClient.DiscoveredOrganization) {
        Task {
            do {
                try await DiscoveryManager.selectDiscoveredOrganization(discoveredOrganization: discoveredOrganization)
                startMFAFlowIfNeeded(configuration: configuration)
            } catch {
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}
