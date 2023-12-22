import UIKit

final class PasswordViewController: BaseViewController<PasswordState, PasswordViewModel> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = .makeTitleLabel()

    private lazy var emailLoginLinkPrimaryButton: Button = .primary(
        title: .emailLoginLink
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        Task {
            do {
                try await self?.viewModel.loginWithEmail(email: email)
            } catch {}
        }
    }

    private lazy var upperSeparator: LabelSeparatorView = .orSeparator()

    private lazy var finishCreatingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.text = NSLocalizedString("stytch.pwFinishCreatingLabel", value: "Finish creating your account by setting a password.", comment: "")
        label.textColor = .primaryText
        return label
    }()

    private let emailInputLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryText
        label.text = NSLocalizedString("stytch.emailInputLabel", value: "Email", comment: "")
        return label
    }()

    private lazy var emailInput: EmailInput = .init()

    private let passwordInputLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryText
        label.text = NSLocalizedString("stytch.passwordInputLabel", value: "Password", comment: "")
        return label
    }()

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .newPassword
        input.textInput.rightView = secureEntryToggleButton
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var secureEntryToggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .secondaryText
        button.addTarget(self, action: #selector(toggleSecureEntry(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 12.5)])
        return button
    }()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in self?.submit() }

    private lazy var forgotPasswordButton: Button = .tertiary(
        title: NSLocalizedString("stytch.forgotPassword", value: "Forgot password?", comment: "")
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        Task {
            do {
                try await self?.viewModel.forgotPassword(email: email)
            } catch {}
        }
    }

    private lazy var lowerSeparator: LabelSeparatorView = .orSeparator()

    private lazy var emailLoginLinkTertiaryButton: Button = .tertiary(
        title: .emailLoginLink
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        Task {
            do {
                try await self?.viewModel.loginWithEmail(email: email)
            } catch {}
        }
    }

    private var strengthCheckWorkItem: DispatchWorkItem?

    init(state: PasswordState) {
        let viewModel = PasswordViewModel(state: state)
        super.init(viewModel: viewModel)
        viewModel.setDelegate(delegate: self)
    }

    override func configureView() {
        super.configureView()

        emailInput.textInput.placeholder = nil
        continueButton.isEnabled = false
        forgotPasswordButton.setTitleColor(.secondaryText, for: .normal)

        passwordInput.onTextChanged = { [weak self] isValid in
            switch self?.viewModel.state.intent {
            case .enterNewPassword, .signup:
                self?.setNeedsStrengthCheck()
            case .none, .login:
                break
            }
            self?.continueButton.isEnabled = isValid
        }

        passwordInput.onReturn = { [weak self] isValid in
            guard isValid else { return }
            self?.submit()
        }

        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])

        attachStackView(within: scrollView, usingLayoutMarginsGuide: false)

        setUpStackView()

        passwordInput.textInput.becomeFirstResponder()

        emailLoginLinkPrimaryButton.isHidden = true
        upperSeparator.isHidden = true
        finishCreatingLabel.isHidden = true
        forgotPasswordButton.isHidden = true
        lowerSeparator.isHidden = true
        emailLoginLinkTertiaryButton.isHidden = true
        emailLoginLinkPrimaryButton.isHidden = true
        passwordInput.progressBar.isHidden = true

        emailInput.textInput.text = viewModel.state.email
        emailInput.isEnabled = true
        passwordInput.textInput.textContentType = .newPassword

        switch viewModel.state.intent {
        case .signup:
            if viewModel.state.magicLinksEnabled {
                titleLabel.text = NSLocalizedString("stytch.pwChooseHowCreate", value: "Choose how you would like to create your account.", comment: "")
                emailLoginLinkPrimaryButton.isHidden = false
                upperSeparator.isHidden = false
                finishCreatingLabel.isHidden = false
            } else {
                titleLabel.text = NSLocalizedString("stytch.pwCreateAccount", value: "Create account", comment: "")
            }
            passwordInput.progressBar.isHidden = false
        case .enterNewPassword:
            passwordInput.progressBar.isHidden = false
            emailInput.isEnabled = false
            titleLabel.text = NSLocalizedString("stytch.pwSetNewPW", value: "Set a new password", comment: "")
        case .login:
            titleLabel.text = NSLocalizedString("stytch.pwLogIn", value: "Log in", comment: "")
            forgotPasswordButton.isHidden = false
            passwordInput.textInput.textContentType = .password
            emailInput.isEnabled = false
            if viewModel.state.magicLinksEnabled {
                lowerSeparator.isHidden = false
                emailLoginLinkTertiaryButton.isHidden = false
            }
        }
    }

    private func setUpStackView() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailLoginLinkPrimaryButton)
        stackView.addArrangedSubview(upperSeparator)
        stackView.addArrangedSubview(finishCreatingLabel)
        stackView.addArrangedSubview(emailInputLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(passwordInputLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(forgotPasswordButton)
        stackView.addArrangedSubview(lowerSeparator)
        stackView.addArrangedSubview(emailLoginLinkTertiaryButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.setCustomSpacing(.spacingHuge, after: titleLabel)
        stackView.setCustomSpacing(.spacingHuge, after: emailLoginLinkPrimaryButton)
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

    private func submit() {
        guard let email = emailInput.text, let password = passwordInput.text else { return }

        switch viewModel.state.intent {
        case let .enterNewPassword(token):
            Task {
                do {
                    try await viewModel.setPassword(token: token, password: password)
                } catch {}
            }
        case .login:
            Task {
                do {
                    try await viewModel.login(email: email, password: password)
                } catch {}
            }
        case .signup:
            Task {
                do {
                    try await viewModel.signup(email: email, password: password)
                } catch {}
            }
        }
    }

    @objc private func toggleSecureEntry(sender _: UIButton) {
        passwordInput.textInput.isSecureTextEntry.toggle()
    }

    private func setNeedsStrengthCheck() {
        guard passwordInput.isValid else {
            passwordInput.setFeedback(nil)
            return
        }
        strengthCheckWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                self?.checkStrength()
            }
        }

        strengthCheckWorkItem = workItem

        DispatchQueue.global().asyncAfter(
            deadline: .now().advanced(by: .milliseconds(250)),
            execute: workItem
        )
    }

    private func checkStrength() {
        guard let password = passwordInput.text, !password.isEmpty else { return }

        Task { @MainActor in
            do {
                let email = emailInput.text == .redactedEmail ? nil : emailInput.text
                let response = try await viewModel.checkStrength(email: email, password: password)
                if let warning = response.feedback?.warning, !warning.isEmpty {
                    passwordInput.setFeedback(.error(warning))
                } else if let feedback = response.feedback?.suggestions.first {
                    passwordInput.setFeedback(.normal(feedback))
                } else {
                    passwordInput.setFeedback(nil)
                }
                passwordInput.progressBar.progress = .init(rawValue: Int(response.score) - 1)
            } catch {
                presentAlert(error: error)
            }
        }
    }
}

extension PasswordViewController: PasswordViewModelDelegate {
    func launchCheckYourEmail(email: String) {
        let controller = ActionableInfoViewController(
            state: .checkYourEmail(config: viewModel.state.config, email: email, retryAction: {})
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchForgotPassword(email: String) {
        let controller = ActionableInfoViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email, retryAction: {})
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}

private extension String {
    static let emailLoginLink: String = NSLocalizedString("stytch.passwordEmailLoginLink", value: "Email me a login link", comment: "")
}
