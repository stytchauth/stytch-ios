import AuthenticationServices
import StytchCore
import UIKit

final class PasswordResetViewController: BaseViewController<PasswordResetState, PasswordResetViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchPasswordResetTitle", value: "Set a new password", comment: "")
    )

    private let passwordInputLabel = UILabel.makePasswordInputLabel()

    private var strengthCheckWorkItem: DispatchWorkItem?

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
        button.tintColor = .secondaryText
        button.addTarget(self, action: #selector(toggleSecureEntry(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.heightAnchor.constraint(equalToConstant: 12.5)])
        return button
    }()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in
        self?.continueWithPasswordResetIfPossible()
    }

    init(state: PasswordResetState) {
        super.init(viewModel: PasswordResetViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(passwordInputLabel)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(secureEntryToggleButton)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        passwordInput.onTextChanged = { [weak self] isValid in
            self?.setNeedsStrengthCheck()
            self?.continueButton.isEnabled = isValid
        }
    }

    @objc private func toggleSecureEntry(sender _: UIButton) {
        passwordInput.textInput.isSecureTextEntry.toggle()
    }

    @objc private func continueWithPasswordResetIfPossible() {
        guard let password = passwordInput.text else {
            return
        }

        Task {
            do {
                try await viewModel.resetPassword(newPassword: password)
                startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
            } catch {
                presentErrorAlert(error: error)
            }
        }
    }

    private func setNeedsStrengthCheck() {
        guard passwordInput.isValid else {
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
                let email = MemberManager.emailAddress
                let response = try await viewModel.checkStrength(emailAddress: email, password: password)

                switch response.strengthPolicy {
                case .zxcvbn:
                    if let zxcvbnFeedback = response.zxcvbnFeedback {
                        passwordInput.setZXCVBNFeedback(
                            suggestions: zxcvbnFeedback.suggestions,
                            warning: zxcvbnFeedback.warning,
                            score: Int(response.score)
                        )
                    } else {
                        passwordInput.setFeedback(nil)
                    }
                case .luds:
                    if let ludsFeedback = response.ludsFeedback {
                        passwordInput.setLUDSFeedback(ludsRequirement: ludsFeedback, breached: response.breachedPassword, passwordConfig: StytchB2BClient.passwordConfig)
                    } else {
                        passwordInput.setFeedback(nil)
                    }
                }
            } catch {
                presentErrorAlert(error: error)
            }
        }
    }
}
