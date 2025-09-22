import StytchCore
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
                DispatchQueue.main.async {
                    self?.launchCheckYourEmail(email: email)
                }
            } catch {
                ErrorPublisher.publishError(error)
                self?.presentErrorAlert(error: error)
            }
        }
    }

    private lazy var upperSeparator: LabelSeparatorView = .orSeparator()

    private lazy var finishCreatingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 18)
        label.text = LocalizationManager.stytch_b2c_password_finish_creating_label
        label.textColor = .primaryText
        return label
    }()

    private let emailInputLabel = UILabel.makeEmailInputLabel()

    private lazy var emailInput: EmailInput = .init()

    private let passwordInputLabel = UILabel.makePasswordInputLabel()

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .newPassword
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_b2c_password_continue_title
    ) { [weak self] in self?.submit() }

    private lazy var forgotPasswordButton: Button = .tertiary(
        title: LocalizationManager.stytch_b2c_password_forgot
    ) { [weak self] in
        guard let email = self?.emailInput.text else { return }
        Task {
            do {
                try await self?.viewModel.forgotPassword(email: email)
                DispatchQueue.main.async {
                    self?.launchForgotPassword(email: email)
                }
            } catch {
                ErrorPublisher.publishError(error)
                self?.presentErrorAlert(error: error)
            }
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
                DispatchQueue.main.async {
                    self?.launchCheckYourEmail(email: email)
                }
            } catch {
                ErrorPublisher.publishError(error)
                self?.presentErrorAlert(error: error)
            }
        }
    }

    private var strengthCheckWorkItem: DispatchWorkItem?

    init(state: PasswordState) {
        super.init(viewModel: PasswordViewModel(state: state))
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

        setupStackView()
        setupScrollView()

        passwordInput.textInput.becomeFirstResponder()

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

        handleIntent(intent: viewModel.state.intent)
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

    private func setupScrollView() {
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
    }

    private func setupStackView() {
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

private extension String {
    static let emailLoginLink: String = LocalizationManager.stytch_b2c_password_email_login_link
}
