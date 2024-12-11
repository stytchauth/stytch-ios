import AuthenticationServices
import StytchCore
import UIKit

final class SMSOTPEntryViewController: BaseViewController<SMSOTPEntryState, SMSOTPEntryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchSMSOTPEntryTitle", value: "Enter passcode", comment: "")
    )

    var timer: Timer?

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
            boldText: MemberManager.phoneNumber,
            fontSize: 18,
            alignment: .left
        )
        stackView.addArrangedSubview(smsConfirmationLabel)

        let otpView = OTPCodeEntryView(frame: .zero)
        otpView.delegate = self
        stackView.addArrangedSubview(otpView)

        stackView.addArrangedSubview(expiryButton)

        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        updateExpiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExpiryText), userInfo: nil, repeats: true)

        NSLayoutConstraint.activate([
            otpView.heightAnchor.constraint(equalToConstant: 50),
        ])

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}

extension SMSOTPEntryViewController: OTPEntryViewControllerProtocol {
    var expirationDate: Date {
        viewModel.state.expirationDate
    }

    func resendCode() {
        Task {
            do {
                if let phoneNumberE164 = MemberManager.phoneNumber {
                    try await AuthenticationOperations.smsSend(phoneNumberE164: phoneNumberE164)
                }
            } catch {
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
        Task {
            do {
                try await viewModel.smsAuthenticate(code: code)
            } catch {
                presentErrorAlert(error: error)
            }
        }
    }
}
