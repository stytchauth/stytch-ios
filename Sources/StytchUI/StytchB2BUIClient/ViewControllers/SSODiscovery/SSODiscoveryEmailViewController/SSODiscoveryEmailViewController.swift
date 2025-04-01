import AuthenticationServices
import StytchCore
import UIKit

final class SSODiscoveryEmailViewController: BaseViewController<SSODiscoveryEmailState, SSODiscoveryEmailViewModel> {
    private lazy var emailInput: EmailInput = .init()

    private lazy var continueButton: Button = .primary(title: "Continue") { [weak self] in
        self?.continueButtonTapped()
    }

    init(state: SSODiscoveryEmailState) {
        super.init(viewModel: SSODiscoveryEmailViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        viewModel.delegate = self

        let titleLabel = UILabel.makeTitleLabel(text: "Enter your email to continue")

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        continueButton.isEnabled = false

        setupEmailInput(input: emailInput)
    }

    private func setupEmailInput(input: EmailInput) {
        input.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (input.hasBeenValid, isValid) {
            case (_, true):
                input.setFeedback(nil)
            case (true, false):
                input.setFeedback(
                    .error(
                        NSLocalizedString("stytch.invalidEmail", value: "Invalid email address, please try again.", comment: "")
                    )
                )
            case (false, false):
                break
            }
        }

        input.onReturn = { [weak self] isValid in
            if isValid == true {
                self?.continueButtonTapped()
            }
        }
    }

    private func continueButtonTapped() {
        viewModel.startSSODiscovery(emailAddress: emailInput.text ?? "")
    }
}

extension SSODiscoveryEmailViewController: SSODiscoveryEmailViewModelDelegate {
    func ssoDiscoveryDidDirectAuthenticate() {
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }

    func ssoDiscoveryDidFindZeroConnections() {
        Task { @MainActor in
            let ssoDiscoveryFallbackViewController = SSODiscoveryFallbackViewController(state: .init(configuration: viewModel.state.configuration))
            navigationController?.pushViewController(ssoDiscoveryFallbackViewController, animated: true)
        }
    }

    func ssoDiscoveryDidFindMultipleConnections() {
        Task { @MainActor in
            let ssoDiscoveryMenuViewController = SSODiscoveryMenuViewController(state: .init(configuration: viewModel.state.configuration))
            navigationController?.pushViewController(ssoDiscoveryMenuViewController, animated: true)
        }
    }

    func ssoDiscoveryDidError(error: Error) {
        ErrorPublisher.publishError(error)
        presentErrorAlert(error: error)
    }
}
