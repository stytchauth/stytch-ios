import AuthenticationServices
import StytchCore
import UIKit

final class SSODiscoveryMenuViewController: BaseViewController<SSODiscoveryMenuState, SSODiscoveryMenuViewModel> {
    let ssoActiveConnections = SSODiscoveryManager.ssoActiveConnections

    init(state: SSODiscoveryMenuState) {
        super.init(viewModel: SSODiscoveryMenuViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        let titleLabel = UILabel.makeTitleLabel(text: "Select a connection to continue")

        stackView.addArrangedSubview(titleLabel)

        ssoActiveConnections.enumerated().forEach { index, ssoActiveConnection in
            let button = makeSSOButton(ssoActiveConnection: ssoActiveConnection)
            button.tag = index
            button.addTarget(self, action: #selector(didTapSSOButton(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc private func didTapSSOButton(sender: UIControl) {
        guard let (_, ssoActiveConnection) = ssoActiveConnections.enumerated().first(where: { $0.offset == sender.tag }) else {
            return
        }
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await AuthenticationOperations.startSSO(
                    configuration: viewModel.state.configuration,
                    connectionId: ssoActiveConnection.connectionId
                )
                StytchB2BUIClient.stopLoading()
                startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
            } catch {
                StytchB2BUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}
