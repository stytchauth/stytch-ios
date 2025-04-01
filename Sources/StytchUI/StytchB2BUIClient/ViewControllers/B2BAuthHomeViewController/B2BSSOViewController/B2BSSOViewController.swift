import AuthenticationServices
import StytchCore
import UIKit

protocol B2BSSOViewControllerDelegate: AnyObject {
    func ssoDidAuthenticatie()
    func didTapSSODiscovery()
}

final class B2BSSOViewController: BaseViewController<SSOState, SSOViewModel> {
    weak var delegate: B2BSSOViewControllerDelegate?
    let ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]

    init(state: SSOState, delegate: B2BSSOViewControllerDelegate?, ssoActiveConnections: [StytchB2BClient.SSOActiveConnection]) {
        self.ssoActiveConnections = ssoActiveConnections
        self.delegate = delegate
        super.init(viewModel: SSOViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        switch viewModel.state.configuration.computedAuthFlowType {
        case .discovery:
            let button = makeSSODiscoveryButton()
            button.addTarget(self, action: #selector(didTapSSODiscoveryButton(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        case .organization(slug: _):
            ssoActiveConnections.enumerated().forEach { index, ssoActiveConnection in
                let button = makeSSOButton(ssoActiveConnection: ssoActiveConnection)
                button.tag = index
                button.addTarget(self, action: #selector(didTapSSOButton(sender:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
        }

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc private func didTapSSODiscoveryButton(sender _: UIControl) {
        delegate?.didTapSSODiscovery()
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
                delegate?.ssoDidAuthenticatie()
                StytchB2BUIClient.stopLoading()
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}
