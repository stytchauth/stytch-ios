import AuthenticationServices
import StytchCore
import UIKit

final class PasswordForgotViewController: BaseViewController<PasswordForgotState, PasswordForgotViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchPasswordForgotTitle", value: "Check your email for help signing in!", comment: "")
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: NSLocalizedString("stytchPasswordForgotSubtitle", value: "We'll email you a login link to sign in to your account directly or reset your password if you have one.", comment: "")
    )

    private let emailInputLabel = UILabel.makeEmailInputLabel()

    private lazy var emailInput: EmailInput = .init()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in
        self?.continueWithPasswordResetIfPossible()
    }

    init(state: PasswordForgotState) {
        super.init(viewModel: PasswordForgotViewModel(state: state))
        viewModel.delegate = self
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(emailInputLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

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
        viewModel.resetPassword(emailAddress: emailAddress)
    }
}

extension PasswordForgotViewController: PasswordForgotViewModelDelegate {
    func didSendResetByEmailStart() {
        StytchB2BUIClient.stopLoading()
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordSetNew)
    }

    func didSendEmailMagicLink() {
        StytchB2BUIClient.stopLoading()
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordResetVerify)
    }

    func didError(error: any Error) {
        StytchB2BUIClient.stopLoading()
        presentErrorAlert(error: error)
    }
}
