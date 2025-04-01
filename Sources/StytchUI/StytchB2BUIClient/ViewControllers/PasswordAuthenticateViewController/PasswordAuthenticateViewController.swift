import AuthenticationServices
import StytchCore
import UIKit

final class PasswordAuthenticateViewController: BaseViewController<B2BPasswordsState, B2BPasswordsViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchPasswordAuthenticateTitle", value: "Log in with email and password", comment: "")
    )

    private let emailInputLabel = UILabel.makeEmailInputLabel()

    private lazy var emailInput: EmailInput = .init()

    private let passwordInputLabel = UILabel.makePasswordInputLabel()

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .password
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in
        self?.submit()
    }

    init(state: B2BPasswordsState) {
        super.init(viewModel: B2BPasswordsViewModel(state: state))
        viewModel.delegate = self
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        let signUpOrResetPasswordButton = Button.createTextButton(
            withPlainText: "",
            boldText: "Sign up or reset password",
            action: #selector(signUpOrResetPasswordButtonTapped),
            target: self
        )

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailInputLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(passwordInputLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(signUpOrResetPasswordButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

        emailInput.setReturnKeyType(returnKeyType: .next)
        emailInput.shouldResignFirstResponderOnReturn = false

        emailInput.onReturn = { [weak self] _ in
            self?.passwordInput.assignFirstResponder()
        }

        passwordInput.onReturn = { [weak self] _ in
            self?.submit()
        }
    }

    @objc private func signUpOrResetPasswordButtonTapped() {
        if emailInput.isValid, let emailAddress = emailInput.text {
            MemberManager.updateMemberEmailAddress(emailAddress)
        }

        navigationController?.pushViewController(PasswordForgotViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
    }

    private func submit() {
        let emailAddress = emailInput.text ?? ""
        let password = passwordInput.text ?? ""
        viewModel.authenticateWithPasswordIfPossible(emailAddress: emailAddress, password: password)
    }
}

extension PasswordAuthenticateViewController: B2BPasswordsViewModelDelegate {
    func didAuthenticate() {
        startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
    }

    func didDiscoveryAuthenticate() {
        startDiscoveryFlowIfNeeded(configuration: viewModel.state.configuration)
    }

    func didSendEmailMagicLink() {
        showEmailConfirmation(configuration: viewModel.state.configuration, type: .passwordResetVerify)
    }

    func didError(error: any Error) {
        showEmailNotEligibleForJitProvioningErrorIfPossible(error)
        passwordInput.updateText("")
    }
}
