import StytchCore
import UIKit

final class PasswordViewController: BaseViewController<PasswordState, PasswordViewModel> {
    private let scrollView: UIScrollView = .init()

    private let titleLabel: UILabel = .makeTitleLabel()

    private lazy var finishCreatingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 18)
        label.text = LocalizationManager.stytch_b2c_password_finish_creating_label
        label.textColor = .primaryText
        return label
    }()

    private lazy var upperSeparator: LabelSeparatorView = .orSeparator()
    private lazy var lowerSeparator: LabelSeparatorView = .orSeparator()

    private lazy var emailInput: EmailInput = .init()

    private lazy var emailLoginLinkPrimaryButton: Button = .hollowPrimary(
        title: LocalizationManager.stytch_b2c_password_email_login_link,
        onTap: { [weak self] in
            self?.handleEmailLoginLinkPrimaryTap()
        }
    )

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .newPassword
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_b2c_password_continue_title
    ) { [weak self] in
        self?.submit()
    }

    private lazy var forgotPasswordButton: Button = .tertiary(
        title: LocalizationManager.stytch_b2c_password_forgot,
        onTap: { [weak self] in
            self?.handleForgotPasswordTap()
        }
    )

    private lazy var emailLoginLinkTertiaryButton: Button = .hollowPrimary(
        title: LocalizationManager.stytch_b2c_password_email_login_link,
        onTap: { [weak self] in
            self?.handleEmailLoginLinkTap()
        }
    )

    private var strengthCheckWorkItem: DispatchWorkItem?

    init(state: PasswordState) {
        super.init(viewModel: PasswordViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        forgotPasswordButton.contentHorizontalAlignment = .right
        forgotPasswordButton.titleLabel?.textAlignment = .right

        emailInput.textInput.placeholder = nil
        continueButton.isEnabled = false
        forgotPasswordButton.setTitleColor(.secondaryText, for: .normal)

        setupPasswordInput()
        setupStackView()

        attachStackViewToScrollView()

        emailLoginLinkPrimaryButton.isHidden = true
        upperSeparator.isHidden = true
        finishCreatingLabel.isHidden = true
        forgotPasswordButton.isHidden = true
        lowerSeparator.isHidden = true
        emailLoginLinkTertiaryButton.isHidden = true
        emailLoginLinkPrimaryButton.isHidden = true
        passwordInput.feedback.isHidden = true

        emailInput.textInput.text = viewModel.state.email
        emailInput.isEnabled = true
        passwordInput.textInput.textContentType = .newPassword
        passwordInput.textInput.placeholder = "Password"

        handleIntent(intent: viewModel.state.intent)
    }

    func setupPasswordInput() {
        passwordInput.textInput.becomeFirstResponder()

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
    }

    private func handleIntent(intent: PasswordState.Intent) {
        switch intent {
        case .signup:
            if viewModel.state.magicLinksEnabled {
                titleLabel.text = LocalizationManager.stytch_b2c_password_choose_how_create
                emailLoginLinkPrimaryButton.isHidden = false
                upperSeparator.isHidden = false
                finishCreatingLabel.isHidden = false
            } else {
                titleLabel.text = LocalizationManager.stytch_b2c_password_create_account
            }
            passwordInput.feedback.isHidden = false

        case .enterNewPassword:
            passwordInput.feedback.isHidden = false
            emailInput.isEnabled = false
            titleLabel.text = LocalizationManager.stytch_b2c_password_set_new_password

        case .login:
            titleLabel.text = LocalizationManager.stytch_b2c_password_log_in
            forgotPasswordButton.isHidden = false
            passwordInput.textInput.textContentType = .password
            emailInput.isEnabled = false

            if viewModel.state.magicLinksEnabled {
                lowerSeparator.isHidden = false
                emailLoginLinkTertiaryButton.isHidden = false
            }
        }
    }

    private func setupStackView() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailLoginLinkPrimaryButton)
        stackView.addArrangedSubview(upperSeparator)
        stackView.addArrangedSubview(finishCreatingLabel)
        stackView.addArrangedSubview(emailInput)
        stackView.addArrangedSubview(passwordInput)

        let forgotPasswordButtonRightAlignedStack = UIStackView(arrangedSubviews: [forgotPasswordButton])
        forgotPasswordButtonRightAlignedStack.axis = .horizontal
        forgotPasswordButtonRightAlignedStack.alignment = .trailing
        forgotPasswordButtonRightAlignedStack.distribution = .fill
        stackView.addArrangedSubview(forgotPasswordButtonRightAlignedStack)

        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(lowerSeparator)
        stackView.addArrangedSubview(emailLoginLinkTertiaryButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.setCustomSpacing(.spacingHuge, after: titleLabel)
        stackView.setCustomSpacing(0, after: passwordInput)
        stackView.setCustomSpacing(32, after: continueButton)
        stackView.setCustomSpacing(32, after: lowerSeparator)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
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
        guard let password = passwordInput.text, password.isEmpty == false else {
            return
        }

        Task { @MainActor in
            do {
                let email = emailInput.text
                let response = try await viewModel.checkStrength(email: email, password: password)

                if let luds = response.feedback?.ludsRequirements {
                    passwordInput.setLUDSFeedback(ludsRequirement: luds, breached: response.breachedPassword, passwordConfig: StytchClient.bootstrapData?.passwordConfig)
                } else if let warning = response.feedback?.warning, let suggestions = response.feedback?.suggestions {
                    passwordInput.setZXCVBNFeedback(suggestions: suggestions, warning: warning, score: Int(response.score))
                } else {
                    passwordInput.feedback.isHidden = true
                    passwordInput.setFeedback(nil)
                }
            } catch {
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}

extension PasswordViewController {
    private func submit() {
        guard let email = emailInput.text,
              let password = passwordInput.text
        else {
            return
        }

        switch viewModel.state.intent {
        case let .enterNewPassword(token):
            Task {
                do {
                    try await viewModel.setPassword(token: token, password: password)
                } catch {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                    ErrorPublisher.publishError(error)
                    presentErrorAlert(error: error)
                }
            }
        case .login:
            Task {
                do {
                    try await viewModel.login(email: email, password: password)
                } catch {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                    ErrorPublisher.publishError(error)
                    presentErrorAlert(error: error)
                }
            }
        case .signup:
            Task {
                do {
                    try await viewModel.signup(email: email, password: password)
                } catch {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                    ErrorPublisher.publishError(error)
                    presentErrorAlert(error: error)
                }
            }
        }
    }

    private func handleForgotPasswordTap() {
        guard let email = emailInput.text else { return }
        Task {
            do {
                try await viewModel.forgotPassword(email: email)
                DispatchQueue.main.async {
                    self.launchForgotPassword(email: email)
                }
            } catch {
                ErrorPublisher.publishError(error)
                self.presentErrorAlert(error: error)
            }
        }
    }

    private func handleEmailLoginLinkTap() {
        guard let email = emailInput.text else { return }
        Task {
            do {
                try await viewModel.loginWithEmail(email: email)
                DispatchQueue.main.async {
                    self.launchCheckYourEmail(email: email)
                }
            } catch {
                ErrorPublisher.publishError(error)
                self.presentErrorAlert(error: error)
            }
        }
    }

    private func handleEmailLoginLinkPrimaryTap() {
        guard let email = emailInput.text else { return }
        Task {
            do {
                try await viewModel.loginWithEmail(email: email)
                DispatchQueue.main.async {
                    self.launchCheckYourEmail(email: email)
                }
            } catch {
                ErrorPublisher.publishError(error)
                self.presentErrorAlert(error: error)
            }
        }
    }
}

protocol PasswordViewModelDelegate: AnyObject {
    func launchCheckYourEmail(email: String)
    func launchForgotPassword(email: String)
}

extension PasswordViewController: PasswordViewModelDelegate {
    func launchCheckYourEmail(email: String) {
        let controller = EmailConfirmationViewController(
            state: .checkYourEmail(config: viewModel.state.config, email: email) {
                try await self.viewModel.loginWithEmail(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchForgotPassword(email: String) {
        let controller = EmailConfirmationViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email) {
                try await self.viewModel.forgotPassword(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}
