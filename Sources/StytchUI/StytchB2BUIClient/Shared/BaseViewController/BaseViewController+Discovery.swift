import StytchCore
import UIKit

extension BaseViewController {
    func startDiscoveryFlowIfNeeded(configuration: StytchB2BUIClient.Configuration) {
        Task { @MainActor in
            let discoveredOrganizations = DiscoveryManager.discoveredOrganizations
            if let singleDiscoveredOrganization = discoveredOrganizations.shouldAllowDirectLoginToOrganization(configuration.directLoginForSingleMembershipOptions) {
                selectDiscoveredOrganization(configuration: configuration, discoveredOrganization: singleDiscoveredOrganization)
            } else {
                navigationController?.popToRootViewController(animated: false)
                let viewController: UIViewController
                if DiscoveryManager.discoveredOrganizations.isEmpty {
                    if configuration.allowCreateOrganization == true, StytchB2BClient.createOrganizationEnabled == true {
                        viewController = CreateOrganizationViewController(state: .init(configuration: configuration))
                    } else {
                        viewController = NoDiscoveredOrganizationsViewController(state: .init(configuration: configuration))
                    }
                } else {
                    viewController = DiscoveredOrganizationsViewController(state: .init(configuration: configuration), discoveredOrganizations: DiscoveryManager.discoveredOrganizations)
                }

                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    func selectDiscoveredOrganization(configuration: StytchB2BUIClient.Configuration, discoveredOrganization: StytchB2BClient.DiscoveredOrganization) {
        Task {
            do {
                try await DiscoveryManager.selectDiscoveredOrganization(
                    configuration: configuration,
                    discoveredOrganization: discoveredOrganization
                )
                startMFAFlowIfNeeded(configuration: configuration)
            } catch {
                presentErrorAlert(error: error)
            }
        }
    }
}
