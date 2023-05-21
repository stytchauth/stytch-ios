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

final class PasswordViewController: BaseViewController<Empty, PasswordVCState, Empty> {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private lazy var emailLoginLinkButton: Button = .primary(
        title: NSLocalizedString("stytch.passwordEmailLoginLink", value: "Email me a login link", comment: "")
    ) { [weak self] in
        //            self?.didTapContinue()
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

    private lazy var continueButton: Button = .primary(title: "Continue") { [weak self] in // FIXME: - localize
//            self?.didTapContinue()
        }

    private lazy var forgotPasswordButton: Button = .tertiary(
        title: NSLocalizedString("stytch.forgotPassword", value: "Forgot password?", comment: "")
    ) { [weak self] in
        //            self?.didTapContinue()
    }

    private lazy var lowerSeparator: LabelSeparatorView = .orSeparator()

    private lazy var emailLoginCodeButton: Button = .tertiary(
        title: NSLocalizedString("stytch.passwordEmailLoginCode", value: "Email me a login code", comment: "")
    ) { [weak self] in
        //            self?.didTapContinue()
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

        stackView.setCustomSpacing(.spacingLarge, after: titleLabel)
        stackView.setCustomSpacing(.spacingLarge, after: emailLoginLinkButton)
        stackView.setCustomSpacing(.spacingLarge, after: upperSeparator)
        stackView.setCustomSpacing(.spacingLarge, after: finishCreatingLabel)
        stackView.setCustomSpacing(.spacingLarge, after: passwordInput)
        stackView.setCustomSpacing(.spacingTiny, after: emailInputLabel)
        stackView.setCustomSpacing(.spacingTiny, after: passwordInputLabel)
        [continueButton, forgotPasswordButton, lowerSeparator].forEach {
            stackView.setCustomSpacing(38.5, after: $0)
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
//
//    func initiatePasswordReset(token: String) {
//        let controller = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
//        controller.addTextField { $0.placeholder = "New password" }
//        controller.addAction(.init(title: "Submit", style: .default) { [weak self, unowned controller] _ in
////            guard let newPassword = controller.textFields?.first?.text, !newPassword.isEmpty else { return }
////            self?.resetPassword(token: token, newPassword: newPassword)
//        })
//        controller.addAction(.init(title: "Cancel", style: .cancel))
//        present(controller, animated: true)
//    }
//
//    private func authenticate() {
//        guard let values = checkAndStoreTextFieldValues() else { return }
//
//        Task {
//            do {
//                _ = try await passwordClient.authenticate(
//                    parameters: .init(
//                        organizationId: values.orgId,
//                        email: values.email,
//                        password: values.password
//                    )
//                )
//            } catch {
//                print(error)
//            }
//        }
//    }
//
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
//    private func resetByEmailStart() {
//        guard let values = checkAndStoreTextFieldValues() else { return }
//        Task {
//            do {
//                _ = try await self.passwordClient.resetByEmailStart(parameters: .init(organizationId: values.orgId, email: values.email, resetPasswordUrl: values.redirectUrl))
//                presentAlert(message: "Check your email!")
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    private func resetBySession() {
//        guard let values = checkAndStoreTextFieldValues() else { return }
//
//        Task {
//            do {
//                _ = try await passwordClient.resetBySession(parameters: .init(organizationId: values.orgId, password: values.password))
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    private func resetByExistingPassword() {
//        guard let values = checkAndStoreTextFieldValues() else { return }
//        let resetPasswordWithNewPassword: (String) -> Void = { [weak self] newPassword in
//            Task {
//                do {
//                    _ = try await self?.passwordClient.resetByExistingPassword(parameters: .init(organizationId: values.orgId, email: values.email, existingPassword: values.password, newPassword: newPassword))
//                }
//            }
//        }
//        let controller = UIAlertController(title: "Enter New Password", message: nil, preferredStyle: .alert)
//        controller.addTextField { $0.placeholder = "New password" }
//        controller.addAction(.init(title: "Cancel", style: .cancel))
//        controller.addAction(.init(title: "OK", style: .default) { [unowned controller] _ in
//            resetPasswordWithNewPassword(controller.textFields![0].text ?? "")
//        })
//    }
//
//    private func resetPassword(token: String, newPassword: String) {
//        Task {
//            do {
//                _ = try await passwordClient.resetByEmail(parameters: .init(token: token, password: newPassword))
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
//
//    private func encodeToJson<T: Encodable>(_ object: T) throws -> String {
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//        let data = try jsonEncoder.encode(object)
//        return String(data: data, encoding: .utf8) ?? "Empty Data"
//    }
//
//    private func checkAndStoreTextFieldValues() -> (orgId: Organization.ID, password: String, email: String, redirectUrl: URL?)? {
//        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return nil }
//
//        let redirectUrl = redirectUrlTextField.text.flatMap(URL.init(string:))
//
//        if let redirectUrl {
//            defaults.set(redirectUrl.absoluteString, forKey: Constants.redirectUrlDefaultsKey)
//        }
//
//        if let email = emailTextField.text, !email.isEmpty {
//            defaults.set(email, forKey: Constants.emailDefaultsKey)
//        }
//        if let orgId = orgIdTextField.text, !orgId.isEmpty {
//            defaults.set(orgId, forKey: Constants.orgIdDefaultsKey)
//        }
//
//        defaults.set(orgId, forKey: Constants.orgIdDefaultsKey)
//
//        return (.init(rawValue: orgId), passwordTextField.text ?? "", emailTextField.text ?? "", redirectUrl)
//    }
}
