import AuthenticationServices
import StytchCore
import UIKit

final class PasswordForgotViewController: BaseViewController<PasswordForgotState, PasswordForgotViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_password_forgot_title
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: LocalizationManager.stytch_b2b_password_forgot_subtitle
    )

    private let emailInputLabel = UILabel.makeEmailInputLabel()

    private lazy var emailInput: EmailInput = .init()

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_continue_button
    ) { [weak self] in
        self?.continueWithPasswordResetIfPossible()
    }

    init(state: PasswordForgotState) {
        super.init(viewModel: PasswordForgotViewModel(state: state))
        viewModel.delegate = self
    }

    override func configureView() {
        super.configureView()

        if let emailAddress = MemberManager.emailAddress {
            emailInput.updateText(emailAddress)
        }

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(emailInputLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

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
                input.setFeedback(.error(LocalizationManager.stytch_invalid_email))
            case (false, false):
                break
            }
        }

        emailInput.onReturn = { [weak self] isValid in
            if isValid == true {
                self?.continueWithPasswordResetIfPossible()
            }
        }
    }

    @objc private func continueWithPasswordResetIfPossible() {
        guard let emailAddress = emailInput.text else {
            return
        }

        StytchB2BUIClient.startLoading()
        viewModel.resetPasswordByEmailIfPossible(emailAddress: emailAddress)
    }
}

extension PasswordForgotViewController: PasswordForgotViewModelDelegate {
    func didSendResetByEmailStart() {
        StytchB2BUIClient.stopLoading()
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordSetNew)
    }

    func didSendDiscoveryResetByEmailStart() {
        StytchB2BUIClient.stopLoading()
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordSetNew)
    }

    func didSendEmailMagicLink() {
        StytchB2BUIClient.stopLoading()
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordResetVerify)
    }

    func didError(error: any Error) {
        showEmailNotEligibleForJitProvioningErrorIfPossible(error)
        StytchB2BUIClient.stopLoading()
    }
}
