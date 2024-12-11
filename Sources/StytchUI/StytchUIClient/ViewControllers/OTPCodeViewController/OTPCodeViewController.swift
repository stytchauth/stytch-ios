import StytchCore
import UIKit

final class OTPCodeViewController: BaseViewController<OTPCodeState, OTPCodeViewModel>, OTPEntryViewControllerProtocol {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.otpTitle", value: "Enter passcode", comment: "")
    )

    private let inputLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 18)
        label.textColor = .primaryText
        label.accessibilityLabel = "inputLabel"
        return label
    }()

    private let codeInput: CodeInput = .init()

    lazy var expiryButton: Button = makeExpiryButton()

    var timer: Timer?

    var expirationDate: Date {
        viewModel.state.codeExpiry
    }

    private lazy var lowerSeparator: LabelSeparatorView = .orSeparator()

    private lazy var passwordTertiaryButton: Button = .tertiary(
        title: .createPasswordInstead
    ) { [weak self] in
        guard let email = self?.viewModel.state.input else { return }
        Task {
            do {
                try await self?.viewModel.forgotPassword(email: email)
                DispatchQueue.main.async {
                    self?.launchPassword(email: email)
                }
            } catch {
                self?.presentErrorAlert(error: error)
            }
        }
    }

    init(state: OTPCodeState) {
        super.init(viewModel: OTPCodeViewModel(state: state))
    }

    // swiftlint:disable:next function_body_length
    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingLarge

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(inputLabel)
        stackView.addArrangedSubview(codeInput)
        stackView.addArrangedSubview(expiryButton)
        stackView.addArrangedSubview(lowerSeparator)
        stackView.addArrangedSubview(passwordTertiaryButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.setCustomSpacing(.spacingHuge, after: titleLabel)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        codeInput.onTextChanged = { [weak self] isValid in
            guard let self, let code = self.codeInput.text, isValid else { return }
            Task {
                do {
                    try await self.viewModel.enterCode(code: code, methodId: self.viewModel.state.methodId)
                } catch let error as StytchAPIError where error.errorType == "otp_code_not_found" {
                    DispatchQueue.main.async {
                        self.showInvalidCode()
                    }
                } catch {
                    try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                    self.presentErrorAlert(error: error)
                }
            }
        }

        codeInput.onReturn = { [weak self] isValid in
            guard let self, let code = self.codeInput.text, isValid else { return }
            Task {
                do {
                    try await self.viewModel.enterCode(code: code, methodId: self.viewModel.state.methodId)
                } catch let error as StytchAPIError where error.errorType == "otp_code_not_found" {
                    DispatchQueue.main.async {
                        self.showInvalidCode()
                    }
                } catch {
                    self.presentErrorAlert(error: error)
                }
            }
        }

        let attributedText = NSMutableAttributedString(string: NSLocalizedString("stytch.otpMessage", value: "A 6-digit passcode was sent to you at ", comment: ""))
        let attributedPhone = NSAttributedString(
            string: viewModel.state.formattedInput,
            attributes: [.font: UIFont.IBMPlexSansSemiBold(size: 18)]
        )
        attributedText.append(attributedPhone)
        attributedText.append(.init(string: "."))
        inputLabel.attributedText = attributedText
        updateExpiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExpiryText), userInfo: nil, repeats: true)

        lowerSeparator.isHidden = !viewModel.state.passwordsEnabled
        passwordTertiaryButton.isHidden = !viewModel.state.passwordsEnabled
    }

    @objc private func updateExpiryText() {
        updateExpirationText()
    }

    private func launchPassword(email: String) {
        let controller = ActionableInfoViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email) {
                try await self.viewModel.forgotPassword(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func resendCode() {
        Task {
            do {
                try await viewModel.resendCode(input: viewModel.state.input)
            } catch {
                presentErrorAlert(error: error)
            }
        }
    }

    func presentCodeResetConfirmation() {
        presentCodeResetConfirmation(message: .localizedStringWithFormat(
            NSLocalizedString("stytch.otpNewCodeWillBeSent", value: "A new code will be sent to %@.", comment: ""), viewModel.state.formattedInput
        ))
    }
}

protocol OTPCodeViewModelDelegate: AnyObject {
    func showInvalidCode()
}

extension OTPCodeViewController: OTPCodeViewModelDelegate {
    func showInvalidCode() {
        codeInput.setFeedback(
            .error(
                NSLocalizedString("stytch.otpError", value: "Invalid passcode, please try again.", comment: "")
            )
        )
    }
}

private extension String {
    static let createPasswordInstead: String = NSLocalizedString("stytch.createPasswordInstead", value: "Create a password instead", comment: "")
}
