import UIKit

struct PasswordVCState {
    enum Intent {
        case signup
        case login
        case enterNewPassword
    }
    let intent: Intent
    let email: String
    let magicLinksEnabled: Bool
}

enum PasswordVCAction {
//    case checkPasswordStrength(email: String, password: String) // FIXME: just make strength call directly in this VC since it's all self contained
    case didTapEmailLoginLink(email: String)
    case didTapLogin(email: String, password: String)
    case didTapSignup(email: String, password: String)
    case didTapSetPassword(email: String, password: String)
    case didTapForgotPassword(email: String)
}

final class PasswordViewController: BaseViewController<Empty, PasswordVCState, PasswordVCAction> {
    private let titleLabel: UILabel = .makeTitleLabel()

    private lazy var emailLoginLinkButton: Button = .primary(
        title: NSLocalizedString("stytch.passwordEmailLoginLink", value: "Email me a login link", comment: "")
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        self?.perform(action: .didTapEmailLoginLink(email: email))
    }

    private lazy var upperSeparator: LabelSeparatorView = .orSeparator()

    private lazy var finishCreatingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.text = NSLocalizedString("stytch.pwFinishCreatingLabel", value: "Finish creating your account by setting a password.", comment: "")
        label.textColor = .label
        return label
    }()

    private let emailInputLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondary
        label.text = NSLocalizedString("stytch.emailInputLabel", value: "Email", comment: "")
        return label
    }()

    private lazy var emailInput: EmailInput = .init()

    private let passwordInputLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondary
        label.text = NSLocalizedString("stytch.passwordInputLabel", value: "Password", comment: "")
        return label
    }()

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .password
        input.textInput.rightView = secureEntryToggleButton
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var secureEntryToggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .secondary
        button.addTarget(self, action: #selector(toggleSecureEntry(sender:)), for: .touchUpInside)
        NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 12.5)])
        return button
    }()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in
        guard let self, let email = self.emailInput.text, let password = self.passwordInput.text else { return }
        switch state.intent {
        case .enterNewPassword:
            self.perform(action: .didTapSetPassword(email: email, password: password))
        case .login:
            self.perform(action: .didTapLogin(email: email, password: password))
        case .signup:
            self.perform(action: .didTapSignup(email: email, password: password))
        }
    }

    private lazy var forgotPasswordButton: Button = .tertiary(
        title: NSLocalizedString("stytch.forgotPassword", value: "Forgot password?", comment: "")
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        self?.perform(action: .didTapForgotPassword(email: email))
    }

    private lazy var lowerSeparator: LabelSeparatorView = .orSeparator()

    private lazy var emailLoginCodeButton: Button = .tertiary(
        title: NSLocalizedString("stytch.passwordEmailLoginCode", value: "Email me a login link", comment: "") // FIXME: guessing this should be link instead of code since this is only EML
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        self?.perform(action: .didTapEmailLoginLink(email: email))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.isEnabled = false
        emailInput.textInput.placeholder = nil
        forgotPasswordButton.setTitleColor(.secondary, for: .normal)

        attachStackView(within: view)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailLoginLinkButton)
        stackView.addArrangedSubview(upperSeparator)
        stackView.addArrangedSubview(finishCreatingLabel)
        stackView.addArrangedSubview(emailInputLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(passwordInputLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(forgotPasswordButton)
        stackView.addArrangedSubview(lowerSeparator)
        stackView.addArrangedSubview(emailLoginCodeButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.setCustomSpacing(.spacingHuge, after: titleLabel)
        stackView.setCustomSpacing(.spacingHuge, after: emailLoginLinkButton)
        stackView.setCustomSpacing(.spacingHuge, after: upperSeparator)
        stackView.setCustomSpacing(.spacingHuge, after: finishCreatingLabel)
        stackView.setCustomSpacing(.spacingHuge, after: passwordInput)
        stackView.setCustomSpacing(.spacingTiny, after: emailInputLabel)
        stackView.setCustomSpacing(.spacingTiny, after: passwordInputLabel)
        [continueButton, forgotPasswordButton, lowerSeparator].forEach {
            stackView.setCustomSpacing(38, after: $0)
        }

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    override func stateDidUpdate(state: State) {
        emailLoginLinkButton.isHidden = true
        upperSeparator.isHidden = true
        finishCreatingLabel.isHidden = true
        forgotPasswordButton.isHidden = true
        lowerSeparator.isHidden = true
        emailLoginCodeButton.isHidden = true
        emailLoginLinkButton.isHidden = true

        emailInput.textInput.text = state.email
        emailInput.isEnabled = true
        passwordInput.textInput.textContentType = .newPassword

        // FIXME: localize
        switch state.intent {
        case .signup:
            if state.magicLinksEnabled {
                titleLabel.text = "Choose how you would like to create your account."
                emailLoginLinkButton.isHidden = false
                upperSeparator.isHidden = false
                finishCreatingLabel.isHidden = false
            } else {
                titleLabel.text = "Create account"
            }
        case .enterNewPassword:
            emailInput.isEnabled = false
            titleLabel.text = "Set a new password"
        case .login:
            titleLabel.text = "Log in"
            forgotPasswordButton.isHidden = false
            passwordInput.textInput.textContentType = .password
            emailInput.isEnabled = false
            if state.magicLinksEnabled {
                lowerSeparator.isHidden = false
                emailLoginCodeButton.isHidden = false
            }
        }
    }

    @objc private func toggleSecureEntry(sender: UIButton) {
        passwordInput.textInput.isSecureTextEntry.toggle()
    }

//    private func checkStrength() {
//        guard let password = passwordTextField.text, !password.isEmpty else { return }
//
//        if let email = emailTextField.text, !email.isEmpty {
//            defaults.set(email, forKey: Constants.emailDefaultsKey)
//        }
//
//        Task {
//            do {
//                let response = try await passwordClient.strengthCheck(parameters: .init(email: emailTextField.text, password: password))
//                presentAlert(message: try encodeToJson(response))
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    private func presentAlert(message: String) {
//        DispatchQueue.main.async {
//            let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//            controller.addAction(.init(title: "OK", style: .default))
//            self.present(controller, animated: true)
//        }
//    }
}
