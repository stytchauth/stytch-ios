import AuthenticationServices
import StytchCore
import UIKit

final class EmailOTPEntryViewController: BaseViewController<EmailOTPEntryState, EmailOTPEntryViewModel> {
    let otpView = OTPCodeEntryView(frame: .zero)

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchEmailOTPEntryTitle", value: "Enter verification code", comment: "")
    )

    var timer: Timer?
    var expirationDate = Date().addingTimeInterval(600)

    lazy var expiryButton: Button = makeExpiryButton()

    init(state: EmailOTPEntryState) {
        super.init(viewModel: EmailOTPEntryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)

        let emailConfirmationLabel = UILabel.makeComboLabel(
            withPlainText: "A 6-digit passcode was sent to you at",
            boldText: MemberManager.emailAddress,
            fontSize: 18,
            alignment: .left
        )
        stackView.addArrangedSubview(emailConfirmationLabel)

        otpView.delegate = self
        stackView.addArrangedSubview(otpView)

        stackView.addArrangedSubview(expiryButton)

        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate([
            otpView.heightAnchor.constraint(equalToConstant: 50),
        ])

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        if viewModel.state.didSendCode == false {
            expiryButton.setTitle("", for: .normal)
            timer?.invalidate()
            resendCode()
        } else {
            startTimer()
        }
    }

    func startTimer() {
        resetExpirationDate()
        timer?.invalidate()
        updateExpiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExpiryText), userInfo: nil, repeats: true)
    }

    func resetExpirationDate() {
        expirationDate = Date().addingTimeInterval(600)
    }
}

extension EmailOTPEntryViewController: OTPEntryViewControllerProtocol {
    func resendCode() {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await AuthenticationOperations.sendEmailOTPForAuthFlowType(configuration: viewModel.state.configuration, emailAddress: MemberManager.emailAddress ?? "")
                startTimer()
                StytchB2BUIClient.stopLoading()
            } catch {
                StytchB2BUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }

    func presentCodeResetConfirmation() {
        guard let emailAddress = MemberManager.emailAddress else {
            return
        }

        presentCodeResetConfirmation(message: .localizedStringWithFormat(
            NSLocalizedString("stytch.otpNewCodeWillBeSent", value: "A new code will be sent to %@.", comment: ""), emailAddress
        ))
    }

    @objc private func updateExpiryText() {
        updateExpirationText()
    }
}

extension EmailOTPEntryViewController: OTPCodeEntryViewDelegate {
    func didEnterOTPCode(_ code: String) {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                if viewModel.state.configuration.computedAuthFlowType == .discovery {
                    try await viewModel.emailDiscoveryAuthenticate(code: code)
                    startDiscoveryFlowIfNeeded(configuration: viewModel.state.configuration)
                } else {
                    try await viewModel.emailAuthenticate(code: code)
                    startMFAFlowIfNeeded(configuration: viewModel.state.configuration)
                }
                StytchB2BUIClient.stopLoading()
            } catch {
                otpView.clear()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}
