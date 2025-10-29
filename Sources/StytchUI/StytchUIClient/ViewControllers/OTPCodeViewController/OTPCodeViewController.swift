import StytchCore
import UIKit

final class OTPCodeViewController: BaseViewController<OTPCodeState, OTPCodeViewModel>, OTPEntryViewControllerProtocol {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2c_otp_title
    )

    private let inputLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .IBMPlexSansRegular(size: 18)
        label.textColor = .primaryText
        label.accessibilityLabel = "inputLabel"
        return label
    }()

    private let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .IBMPlexSansSemiBold(size: 18)
        label.textColor = .primaryText
        label.accessibilityLabel = "phoneNumberLabel"
        return label
    }()

    private lazy var resendCodeButton: UIButton = {
        let button = Button.primary(
            title: "Resend Code"
        ) { [weak self] in
            self?.resendCode()
        }
        return button
    }()

    private let otpView = OTPCodeEntryView(frame: .zero)

    lazy var expiryButton: Button = makeExpiryButton()

    var timer: Timer?

    var expirationDate: Date {
        viewModel.state.codeExpiry
    }

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
                ErrorPublisher.publishError(error)
                self?.presentErrorAlert(error: error)
            }
        }
    }

    init(state: OTPCodeState) {
        super.init(viewModel: OTPCodeViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .init(top: .verticalMargin, left: 48, bottom: .verticalMargin, right: 48)

        stackView.spacing = .spacingLarge

        stackView.addArrangedSubview(titleLabel)

        let inputStack = makeVerticalStack(with: [inputLabel, phoneNumberLabel], spacing: .spacingTiny)
        stackView.addArrangedSubview(inputStack)

        let otpStack = makeVerticalStack(with: [otpView, expiryButton], spacing: .spacingTiny)
        stackView.addArrangedSubview(otpStack)

        let buttonStack = makeVerticalStack(with: [resendCodeButton, passwordTertiaryButton], spacing: .spacingTiny)
        stackView.addArrangedSubview(buttonStack)

        stackView.addArrangedSubview(SpacerView())

        stackView.setCustomSpacing(.spacingHuge, after: titleLabel)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            otpView.heightAnchor.constraint(equalToConstant: 50),
        ])

        inputLabel.text = LocalizationManager.stytch_b2c_otp_message
        phoneNumberLabel.text = viewModel.state.formattedInput
        passwordTertiaryButton.isHidden = !viewModel.state.passwordsEnabled

        otpView.delegate = self

        startTimer()
    }

    @objc private func updateExpiryText() {
        updateExpirationText()
    }

    private func launchPassword(email: String) {
        let controller = EmailConfirmationViewController(
            state: .forgotPassword(config: viewModel.state.config, email: email) {
                try await self.viewModel.forgotPassword(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func startTimer() {
        timer?.invalidate()
        timer = nil
        updateExpiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExpiryText), userInfo: nil, repeats: true)
    }

    func resendCode() {
        Task {
            do {
                try await viewModel.resendCode(input: viewModel.state.input)
                startTimer()
            } catch {
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }

    func presentCodeResetConfirmation() {
        presentCodeResetConfirmation(recipient: viewModel.state.formattedInput)
    }
}

extension OTPCodeViewController: OTPCodeEntryViewDelegate {
    func didEnterOTPCode(_ code: String) {
        StytchUIClient.startLoading()
        Task {
            do {
                try await self.viewModel.enterCode(code: code, methodId: self.viewModel.state.methodId)
                StytchUIClient.stopLoading()
            } catch let error as StytchAPIError where error.errorType == .otpCodeNotFound {
                DispatchQueue.main.async {
                    self.presentAlert(title: LocalizationManager.stytch_b2c_otp_error)
                }
                self.otpView.clear()
                StytchUIClient.stopLoading()
            } catch {
                try? await EventsClient.logEvent(parameters: .init(eventName: "ui_authentication_failure", error: error))
                ErrorPublisher.publishError(error)
                self.presentErrorAlert(error: error)
                self.otpView.clear()
                StytchUIClient.stopLoading()
            }
        }
    }
}

private extension String {
    static let createPasswordInstead: String = LocalizationManager.stytch_b2c_create_password_instead
}
