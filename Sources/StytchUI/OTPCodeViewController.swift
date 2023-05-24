import UIKit

final class OTPCodeViewController: BaseViewController<OTPVCState, OTPVCAction> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.otpTitle", value: "Enter passcode", comment: "")
    )

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .primaryText
        return label
    }()

    private let codeInput: CodeInput = .init()

    private lazy var expiryButton: Button = {
        let button = Button.tertiary(
            title: ""
        ) { [weak self] in
            self?.presentCodeResetConfirmation()
        }
        button.setTitleColor(.secondary, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        return button
    }()

    private let dateFormatter: DateComponentsFormatter = {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.minute, .second]
        return dateFormatter
    }()

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.spacing = .spacingLarge

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(phoneLabel)
        stackView.addArrangedSubview(codeInput)
        stackView.addArrangedSubview(expiryButton)
        stackView.addArrangedSubview(SpacerView())

        stackView.setCustomSpacing(.spacingHuge, after: titleLabel)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        codeInput.onTextChanged = { [weak self] isValid in
            guard let self, let code = self.codeInput.text, isValid else { return }

            self.perform(action: .didEnterCode(code, methodId: state.methodId, controller: self))
        }

        codeInput.onReturn = { [weak self] isValid in
            guard let self, let code = self.codeInput.text, isValid else { return }

            self.perform(action: .didEnterCode(code, methodId: state.methodId, controller: self))
        }
    }

    override func stateDidUpdate(state: State) {
        let attributedText = NSMutableAttributedString(string: NSLocalizedString("stytch.otpMessage", value: "A 6-digit passcode was sent to you at ", comment: ""))
        let attributedPhone = NSAttributedString(
            string: state.formattedPhoneNumber,
            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        )
        attributedText.append(attributedPhone)
        attributedText.append(.init(string: "."))
        phoneLabel.attributedText = attributedText
        updateExiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExiryText), userInfo: nil, repeats: true)
    }

    func showInvalidCode() {
        codeInput.setFeedback(
            .error(
                NSLocalizedString("stytch.otpError", value: "Invalid passcode, please try again.", comment: "")
            )
        )
    }

    @objc private func updateExiryText() {
        guard
            case let currentDate = Date(),
            state.codeExpiry > currentDate,
            let dateString = dateFormatter.string(from: currentDate, to: state.codeExpiry)
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

    private func resendCode() {
        perform(action: .didTapResendCode(phone: state.phoneNumberE164, controller: self))
    }

    private func presentCodeResetConfirmation() {
        let controller = UIAlertController(
            title: NSLocalizedString("stytch.otpResendCode", value: "Resend code", comment: ""),
            message: .localizedStringWithFormat(
                NSLocalizedString("stytch.otpNewCodeWillBeSent", value: "A new code will be sent to %@.", comment: ""), state.formattedPhoneNumber
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

enum OTPVCAction {
    case didTapResendCode(phone: String, controller: OTPCodeViewController)
    case didEnterCode(_ code: String, methodId: String, controller: OTPCodeViewController)
}

struct OTPVCState {
    let phoneNumberE164: String
    let formattedPhoneNumber: String
    let methodId: String
    let codeExpiry: Date
}
