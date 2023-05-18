import UIKit

final class AuthInputViewController: BaseViewController<InputAction, StytchUIClient.Configuration.Input> {
    private enum Input {
        case email
        case phone
    }

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 12
        return view
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Text", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Email", at: 0, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let phoneNumberInput: PhoneNumberInput = .init()

    private var phoneNumberHasBeenValid = false

    private let emailInput: EmailInput = .init()

    private var emailHasBeenValid = false

    private lazy var continueButton: UIButton = {
        let button = Button.primary(title: "Continue") { [weak self] in
            self?.didTapContinue()
        }
        button.isEnabled = false
        return button
    }()

    private var activeInput: Input = .email {
        didSet {
            phoneNumberInput.isHidden = activeInput == .email
            emailInput.isHidden = activeInput == .phone
        }
    }

    private var isCurrentInputValid: Bool {
        switch activeInput {
        case .email:
            return emailInput.isValid
        case .phone:
            return phoneNumberInput.isValid
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch configuration {
        case let .magicLink(sms), let .password(sms), let .magicLinkAndPassword(sms):
            if sms {
                segmentedControl.addTarget(self, action: #selector(segmentDidUpdate(sender:)), for: .primaryActionTriggered)
                stackView.addArrangedSubview(segmentedControl)

                stackView.addArrangedSubview(phoneNumberInput)
            }
            stackView.addArrangedSubview(emailInput)
            activeInput = .email
        case .smsOnly:
            stackView.addArrangedSubview(phoneNumberInput)
            activeInput = .phone
        }
        stackView.addArrangedSubview(continueButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        var constraints: [NSLayoutConstraint] = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        constraints.append(
            contentsOf: stackView.arrangedSubviews
                .map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
        NSLayoutConstraint.activate(constraints)

        phoneNumberInput.onButtonPressed = { [weak self] phoneNumberKit in
            guard let self else { return }
            self.perform(action: .didTapCountryCode(input: self.phoneNumberInput))
        }

        phoneNumberInput.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (self.phoneNumberHasBeenValid, isValid) {
            case (_, true):
                self.phoneNumberHasBeenValid = true
                self.phoneNumberInput.setErrorText(nil)
            case (true, false):
                self.phoneNumberInput.setErrorText(
                    NSLocalizedString("stytch.invalidNumber", value: "Invalid number, please try again.", comment: "")
                )
            case (false, false):
                break
            }
        }

        emailInput.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (self.emailHasBeenValid, isValid) {
            case (_, true):
                self.emailHasBeenValid = true
                self.emailInput.setErrorText(nil)
            case (true, false):
                self.emailInput.setErrorText(
                    NSLocalizedString("stytch.invalidEmail", value: "Invalid email address, please try again.", comment: "")
                )
            case (false, false):
                break
            }
        }

        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    @objc private func segmentDidUpdate(sender: UISegmentedControl) {
        activeInput = sender.selectedSegmentIndex == 0 ? .email : .phone
        continueButton.isEnabled = isCurrentInputValid
    }

    @objc private func didTapContinue() {
        switch activeInput {
        case .email:
            perform(action: .didTapContinueEmail(email: emailInput.text ?? ""))
        case .phone:
            perform(action: .didTapContinuePhone(phone: phoneNumberInput.phoneNumberE164 ?? ""))
        }
    }
}
//            switch configuration {
//            case .magicLink:
//            case .password:
//            default:
//            }
//            perform(action: .)

//        Task {
//            do {
//                guard let phoneNumber = phoneNumberInput.phoneNumberE164 else { return }
//
//                let codeExpiry = Date().addingTimeInterval(120)
//
//                let result = try await StytchClient.otps.loginOrCreate(parameters: .init(deliveryMethod: .sms(phoneNumber: phoneNumber), expiration: 2))
//
//                let controller = OTPCodeViewController()
//                controller.configure(
//                    phoneNumberE164: phoneNumber,
//                    formattedPhoneNumber: phoneNumberInput.formattedPhoneNumber!,
//                    methodId: result.methodId,
//                    codeExpiry: codeExpiry
//                ) { [weak self, weak controller] response in
//                    controller?.dismiss(animated: true)
//                    self?.authenticate(response: response)
//                }
//                self.present(controller, animated: true)
//            } catch {
//                print(error)
//            }
//        }
