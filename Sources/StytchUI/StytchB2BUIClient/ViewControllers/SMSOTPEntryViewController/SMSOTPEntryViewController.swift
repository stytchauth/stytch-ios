import AuthenticationServices
import StytchCore
import UIKit

final class SMSOTPEntryViewController: BaseViewController<SMSOTPEntryState, SMSOTPEntryViewModel> {
    let otpView = OTPCodeEntryView(frame: .zero)

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchSMSOTPEntryTitle", value: "Enter passcode", comment: "")
    )

    var timer: Timer?

    var expirationDate = Date().addingTimeInterval(120)

    lazy var expiryButton: Button = makeExpiryButton()

    init(state: SMSOTPEntryState) {
        super.init(viewModel: SMSOTPEntryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)

        let smsConfirmationLabel = UILabel.makeComboLabel(
            withPlainText: "A 6-digit passcode was sent to you at",
            boldText: MemberManager.formattedPhoneNumber,
            fontSize: 18,
            alignment: .left
        )
        stackView.addArrangedSubview(smsConfirmationLabel)

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

        if MemberManager.member?.mfaPhoneNumberVerified == true {
            hideBackButton()
        }
    }

    func startTimer() {
        resetExpirationDate()
        timer?.invalidate()
        updateExpiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExpiryText), userInfo: nil, repeats: true)
    }

    func resetExpirationDate() {
        expirationDate = Date().addingTimeInterval(121)
    }
}

extension SMSOTPEntryViewController: OTPEntryViewControllerProtocol {
    func resendCode() {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                if let phoneNumberE164 = MemberManager.phoneNumber {
                    try await AuthenticationOperations.smsSend(phoneNumberE164: phoneNumberE164)
                    startTimer()
                }
                StytchB2BUIClient.stopLoading()
            } catch {
                StytchB2BUIClient.stopLoading()
                presentErrorAlert(error: error)
            }
        }
    }

    func presentCodeResetConfirmation() {
        guard let phoneNumber = MemberManager.phoneNumber else {
            return
        }

        presentCodeResetConfirmation(message: .localizedStringWithFormat(
            NSLocalizedString("stytch.otpNewCodeWillBeSent", value: "A new code will be sent to %@.", comment: ""), phoneNumber
        ))
    }

    @objc private func updateExpiryText() {
        updateExpirationText()
    }
}

extension SMSOTPEntryViewController: OTPCodeEntryViewDelegate {
    func didEnterOTPCode(_ code: String) {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await viewModel.smsAuthenticate(code: code)
                StytchB2BUIClient.stopLoading()
            } catch {
                otpView.clear()
                presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}
