import AuthenticationServices
import StytchCore
import UIKit

final class DiscoveryViewController: BaseViewController<DiscoveryState, DiscoveryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchDiscoveryTitle", value: "Select an organization to continue", comment: "")
    )

    init(state: DiscoveryState) {
        super.init(viewModel: DiscoveryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)

        let discoveredOrganizationsViewController = DiscoveredOrganizationsViewController(discoveredOrganizations: DiscoveryManager.discoveredOrganizations)
        discoveredOrganizationsViewController.delegate = self
        addChild(discoveredOrganizationsViewController)
        stackView.addArrangedSubview(discoveredOrganizationsViewController.view)
        discoveredOrganizationsViewController.didMove(toParent: self)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}

extension DiscoveryViewController: DiscoveredOrganizationsViewControllerDelegate {
    func didSelectDiscoveredOrganization(discoveredOrganization: StytchCore.StytchB2BClient.DiscoveredOrganization) {
        selectDiscoveredOrganization(configuration: viewModel.state.configuration, discoveredOrganization: discoveredOrganization)
    }
}
