import StytchCore
import UIKit

enum OTPVCAction {
    case didTapResendCode(phone: String)
    case didEnterCode(_ code: String, methodId: String)
}

struct OTPVCState {
    let phoneNumberE164: String
    let formattedPhoneNumber: String
    let methodId: String
    let codeExpiry: Date
}

final class OTPCodeViewController: BaseViewController<Empty, OTPVCState, OTPVCAction> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytch.otpTitle", value: "Enter passcode", comment: "")
    )

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .brand
        return label
    }()

    private let codeInput: CodeInput = .init()

    private lazy var expiryButton: Button = {
        let button = Button.tertiary(
            title: ""
        ) { [weak self] in
            guard let self else { return }
            self.perform(action: .didTapResendCode(phone: self.state.phoneNumberE164))
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
            guard let self, let code = self.codeInput.text, code.count == 6 else { return }

            self.perform(action: .didEnterCode(code, methodId: state.methodId))
            // TODO: find way to communicate error back to this VC

        }
        // FIXME: for error
        if false {
            self.codeInput.setErrorText(NSLocalizedString("stytch.otpError", value: "Invalid passcode, please try again.", comment: "")
            )
        } else {
            self.codeInput.setErrorText(nil)
        }

        expiryButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
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

//        Task {
//            do {
//                let result = try await StytchClient.otps.authenticate(parameters: .init(code: code, methodId: methodId))
//                onAuthenticate(result)
//            } catch let error as StytchError where error.errorType == "otp_code_not_found" {
//                stackView.setCustomSpacing(2, after: codeField)
//                errorLabel.isHidden = false
//            }
//        }

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

    @objc private func resendCode() {
        perform(action: .didTapResendCode(phone: state.phoneNumberE164)) // FIXME: perhaps this should be self contained, similar to pw strength check
//        Task {
//            do {
//                codeExpiry = Date().addingTimeInterval(120)
//                let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phoneNumberE164), expiration: 2))
//                methodId = result.methodId
//            } catch {
//                print(error)
//            }
//        }
    }

    private func expiryAttributedText(initialSegment: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: initialSegment + NSLocalizedString("stytch.otpDidntGetIt", value: " Didn't get it?", comment: ""), attributes: [.font: UIFont.systemFont(ofSize: 16)])
        let appendedAttributedString = NSAttributedString(string: NSLocalizedString("stytch.otpResendIt", value: " Resend it.", comment: ""), attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
        attributedString.append(appendedAttributedString)
        return attributedString
    }
}
