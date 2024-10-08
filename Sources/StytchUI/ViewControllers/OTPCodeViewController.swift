import StytchCore
import UIKit

final class OTPCodeViewController: BaseViewController<OTPCodeState, OTPCodeViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.otpTitle", value: "Enter passcode", comment: "")
    )

    private let inputLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .primaryText
        label.accessibilityLabel = "inputLabel"
        return label
    }()

    private let codeInput: CodeInput = .init()

    private lazy var expiryButton: Button = {
        let button = Button.tertiary(
            title: ""
        ) { [weak self] in
            self?.presentCodeResetConfirmation()
        }
        button.setTitleColor(.secondaryText, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        button.accessibilityLabel = "expiryButton"
        return button
    }()

    private let dateFormatter: DateComponentsFormatter = {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.minute, .second]
        return dateFormatter
    }()

    private var timer: Timer?

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
                self?.presentAlert(error: error)
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
                    self.presentAlert(error: error)
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
                    self.presentAlert(error: error)
                }
            }
        }

        let attributedText = NSMutableAttributedString(string: NSLocalizedString("stytch.otpMessage", value: "A 6-digit passcode was sent to you at ", comment: ""))
        let attributedPhone = NSAttributedString(
            string: viewModel.state.formattedInput,
            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
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
        guard
            case let currentDate = Date(),
            viewModel.state.codeExpiry > currentDate,
            let dateString = dateFormatter.string(from: currentDate, to: viewModel.state.codeExpiry)
        else {
            expiryButton.setAttributedTitle(
                expiryAttributedText(initialSegment: NSLocalizedString("stytch.otpCodeExpired", value: "Your code has expired.", comment: "")),
                for: .normal
            )
            timer?.invalidate()
            return
        }

        expiryButton.setAttributedTitle(
            expiryAttributedText(initialSegment: .localizedStringWithFormat(NSLocalizedString("stytch.otpCodeExpiresIn", value: "Your code expires in %@.", comment: ""), dateString)),
            for: .normal
        )
    }

    private func launchPassword(email: String) {
        let controller = ActionableInfoViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email) {
                try await self.viewModel.forgotPassword(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    private func resendCode() {
        Task {
            do {
                try await viewModel.resendCode(input: viewModel.state.input)
            } catch {
                presentAlert(error: error)
            }
        }
    }

    private func presentCodeResetConfirmation() {
        let controller = UIAlertController(
            title: NSLocalizedString("stytch.otpResendCode", value: "Resend code", comment: ""),
            message: .localizedStringWithFormat(
                NSLocalizedString("stytch.otpNewCodeWillBeSent", value: "A new code will be sent to %@.", comment: ""), viewModel.state.formattedInput
            ),
            preferredStyle: .alert
        )
        controller.addAction(.init(title: NSLocalizedString("stytch.otpCancel", value: "Cancel", comment: ""), style: .default))
        controller.addAction(.init(title: NSLocalizedString("stytch.otpConfirm", value: "Send code", comment: ""), style: .default) { [weak self] _ in
            self?.resendCode()
        })
        controller.view.tintColor = .primaryText
        present(controller, animated: true)
    }

    private func expiryAttributedText(initialSegment: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: initialSegment + NSLocalizedString("stytch.otpDidntGetIt", value: " Didn't get it?", comment: ""), attributes: [.font: UIFont.systemFont(ofSize: 16)])
        let appendedAttributedString = NSAttributedString(string: NSLocalizedString("stytch.otpResendIt", value: " Resend it.", comment: ""), attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
        attributedString.append(appendedAttributedString)
        return attributedString
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
