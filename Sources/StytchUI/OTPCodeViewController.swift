import StytchCore
import UIKit

final class OTPCodeViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 24
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .brand
        label.text = NSLocalizedString("stytch.otpTitle", value: "Enter passcode", comment: "")
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = .brand
        return label
    }()

    private let codeField: UITextField = {
        let field = UITextField()
        field.layer.borderColor = UIColor.placeholder.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = .cornerRadius
        field.textContentType = .oneTimeCode
        let view = UIView(frame: .init(x: 0, y: 0, width: 10, height: 10))
        field.leftView = view
        field.leftViewMode = .always
        return field
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .error
        label.text = NSLocalizedString("stytch.otpError", value: "Invalid passcode, please try again.", comment: "")
        label.isHidden = true
        return label
    }()

    private let expiryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.secondary, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.numberOfLines = 0
        return button
    }()

    private let poweredByStytch: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "PoweredByStytch")
        return view
    }()

    private let dateFormatter: DateComponentsFormatter = {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.minute, .second]
        return dateFormatter
    }()

    private var timer: Timer?

    private var methodId = ""

    private var phoneNumberE164 = ""

    private var codeExpiry = Date()

    private var onAuthenticate: (AuthenticateResponse) -> Void = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(phoneLabel)
        stackView.addArrangedSubview(codeField)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(expiryButton)
        stackView.addArrangedSubview(poweredByStytch)
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.addArrangedSubview(spacerView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .horizontalMargin),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.horizontalMargin),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .verticalMargin),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.verticalMargin),
            codeField.heightAnchor.constraint(equalToConstant: 45),
            codeField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            errorLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            expiryButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: codeField, queue: .main) { [weak self] notification in
            self?.textChanged()
        }

        expiryButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
    }

    func configure(
        phoneNumberE164: String,
        formattedPhoneNumber: String,
        methodId: String,
        codeExpiry: Date,
        onAuthenticate: @escaping (AuthenticateResponseType) -> Void
    ) {
        self.phoneNumberE164 = phoneNumberE164
        self.methodId = methodId
        self.codeExpiry = codeExpiry
        self.onAuthenticate = onAuthenticate
        let attributedText = NSMutableAttributedString(string: NSLocalizedString("stytch.otpMessage", value: "A 6-digit passcode was sent to you at ", comment: ""))
        let attributedPhone = NSAttributedString(
            string: formattedPhoneNumber,
            attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        )
        attributedText.append(attributedPhone)
        attributedText.append(.init(string: "."))
        phoneLabel.attributedText = attributedText
        updateExiryText()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateExiryText), userInfo: nil, repeats: true)
    }

    private func textChanged() {
        errorLabel.isHidden = true
        stackView.setCustomSpacing(stackView.spacing, after: codeField)

        guard let code = codeField.text, code.count == 6 else { return }

        Task {
            do {
                let result = try await StytchClient.otps.authenticate(parameters: .init(code: code, methodId: methodId))
                onAuthenticate(result)
            } catch let error as StytchError where error.errorType == "otp_code_not_found" {
                stackView.setCustomSpacing(2, after: codeField)
                errorLabel.isHidden = false
            }
        }
    }

    @objc private func updateExiryText() {
        guard
            case let currentDate = Date(),
            codeExpiry > currentDate,
            let dateString = dateFormatter.string(from: currentDate, to: codeExpiry)
        else {
            expiryButton.setAttributedTitle(
                expiryAttributedText(initialSegment: NSLocalizedString("stytch.otpCodeExpired", value: "Your code has expired.", comment: "")),
                for: .normal
            )
            timer?.invalidate()
            return
        }

        expiryButton.setAttributedTitle(
            expiryAttributedText(initialSegment: .localizedStringWithFormat(NSLocalizedString("stytch.otpCodeExpiresIn", value: "Your code expires in %s.", comment: ""), dateString)),
            for: .normal
        )
    }

    @objc private func resendCode() {
        Task {
            do {
                codeExpiry = Date().addingTimeInterval(120)
                let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phoneNumberE164), expiration: 2))
                methodId = result.methodId
            } catch {
                print(error)
            }
        }
    }

    private func expiryAttributedText(initialSegment: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: initialSegment + NSLocalizedString("stytch.otpDidntGetIt", value: " Didn't get it?", comment: ""), attributes: [.font: UIFont.systemFont(ofSize: 16)])
        let appendedAttributedString = NSAttributedString(string: NSLocalizedString("stytch.otpResendIt", value: " Resend it.", comment: ""), attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
        attributedString.append(appendedAttributedString)
        return attributedString
    }
}
