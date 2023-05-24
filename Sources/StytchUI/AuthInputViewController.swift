import UIKit

enum AuthInputVCAction {
    case didTapCountryCode(input: PhoneNumberInput)
    case didTapContinueEmail(email: String)
    case didTapContinuePhone(phone: String, formattedPhone: String)
}

final class AuthInputViewController: BaseViewController<StytchUIClient.Configuration, AuthInputVCAction> {
    private enum Input {
        case email
        case phone
    }

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Text", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Email", at: 0, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let phoneNumberInput: PhoneNumberInput = .init()

    private let emailInput: EmailInput = .init()

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

        view.layoutMargins = .zero

        if state.sms != nil, state.magicLink == nil, state.password == nil {
            stackView.addArrangedSubview(phoneNumberInput)
            activeInput = .phone
        } else {
            if state.sms != nil {
                segmentedControl.addTarget(self, action: #selector(segmentDidUpdate(sender:)), for: .primaryActionTriggered)
                stackView.addArrangedSubview(segmentedControl)

                stackView.addArrangedSubview(phoneNumberInput)
            }
            stackView.addArrangedSubview(emailInput)
            activeInput = .email
        }
        stackView.addArrangedSubview(continueButton)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        setUpInputs()
    }

    private func setUpInputs() {
        phoneNumberInput.onButtonPressed = { [weak self] _ in
            guard let self else { return }
            self.perform(action: .didTapCountryCode(input: self.phoneNumberInput))
        }

        phoneNumberInput.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (self.phoneNumberInput.hasBeenValid, isValid) {
            case (_, true):
                self.phoneNumberInput.setFeedback(nil)
            case (true, false):
                self.phoneNumberInput.setFeedback(
                    .error(
                        NSLocalizedString("stytch.invalidNumber", value: "Invalid number, please try again.", comment: "")
                    )
                )
            case (false, false):
                break
            }
        }

        emailInput.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (self.emailInput.hasBeenValid, isValid) {
            case (_, true):
                self.emailInput.setFeedback(nil)
            case (true, false):
                self.emailInput.setFeedback(
                    .error(
                        NSLocalizedString("stytch.invalidEmail", value: "Invalid email address, please try again.", comment: "")
                    )
                )
            case (false, false):
                break
            }
        }
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
            perform(
                action: .didTapContinuePhone(
                    phone: phoneNumberInput.phoneNumberE164 ?? "",
                    formattedPhone: phoneNumberInput.formattedPhoneNumber ?? ""
                )
            )
        }
    }
}
