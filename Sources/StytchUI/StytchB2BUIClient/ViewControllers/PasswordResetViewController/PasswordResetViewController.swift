import AuthenticationServices
import StytchCore
import UIKit

final class PasswordResetViewController: BaseViewController<PasswordResetState, PasswordResetViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_password_reset_title
    )

    private let passwordInputLabel = UILabel.makePasswordInputLabel()

    private var strengthCheckWorkItem: DispatchWorkItem?

    private lazy var passwordInput: SecureTextInput = {
        let input: SecureTextInput = .init(frame: .zero)
        input.textInput.textContentType = .password
        input.textInput.rightViewMode = .always
        return input
    }()

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_b2c_password_continue_title
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
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

        passwordInput.onTextChanged = { [weak self] isValid in
            self?.setNeedsStrengthCheck()
            self?.continueButton.isEnabled = isValid
        }

        passwordInput.onReturn = { [weak self] isValid in
            if isValid == true {
                self?.continueWithPasswordResetIfPossible()
            }
        }
    }

    @objc private func continueWithPasswordResetIfPossible() {
        guard let password = passwordInput.text else {
            return
        }

        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await viewModel.resetPassword(newPassword: password)
                StytchB2BUIClient.stopLoading()
                if viewModel.state.configuration.computedAuthFlowType == .discovery {
                    startDiscoveryFlowIfNeeded(configuration: viewModel.state.configuration)
                } else {
                    startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
                }
            } catch {
                StytchB2BUIClient.stopLoading()
                ErrorPublisher.publishError(error)
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
                        passwordInput.setLUDSFeedback(
                            ludsRequirement: ludsFeedback,
                            breached: response.breachedPassword,
                            passwordConfig: StytchB2BClient.bootstrapData?.passwordConfig
                        )
                    } else {
                        passwordInput.setFeedback(nil)
                    }
                }
            } catch {
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}
