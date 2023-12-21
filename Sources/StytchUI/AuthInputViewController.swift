import UIKit

final class AuthInputViewModel: BaseViewModel<AuthInputState, AuthInputAction> {
    // TODO: Add view model logic
}

final class AuthInputViewController: BaseViewController<AuthInputState, AuthInputAction, AuthInputViewModel> {
    private enum Input {
        case email
        case phone
    }

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(
            withTitle: NSLocalizedString("stytch.aivcText", value: "Text", comment: ""),
            at: 0,
            animated: false
        )
        segmentedControl.insertSegment(
            withTitle: NSLocalizedString("stytch.aivcEmail", value: "Email", comment: ""),
            at: 0,
            animated: false
        )
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let phoneNumberInput: PhoneNumberInput = .init()

    private let emailInput: EmailInput = .init()

    private lazy var continueButton: UIButton = {
        let button = Button.primary(
            title: NSLocalizedString("stytch.aivcContinue", value: "Continue", comment: "")
        ) { [weak self] in
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

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        if viewModel.state.config.sms != nil, viewModel.state.config.magicLink == nil, viewModel.state.config.password == nil {
            stackView.addArrangedSubview(phoneNumberInput)
            activeInput = .phone
        } else {
            if viewModel.state.config.sms != nil {
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

        setupInputs()
    }

    private func setupInputs() {
        phoneNumberInput.onButtonPressed = { [weak self] _ in
            guard let self else { return }
            viewModel.performAction(.didTapCountryCode(input: self.phoneNumberInput))
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
            viewModel.perform(action: .didTapContinueEmail(email: emailInput.text ?? ""))
        case .phone:
            viewModel.perform(
                action: .didTapContinuePhone(
                    phone: phoneNumberInput.phoneNumberE164 ?? "",
                    formattedPhone: phoneNumberInput.formattedPhoneNumber ?? ""
                )
            )
        }
    }
}

struct AuthInputState: BaseState {
    let config: StytchUIClient.Configuration
}

enum AuthInputAction: BaseAction {
    case didTapCountryCode(input: PhoneNumberInput)
    case didTapContinueEmail(email: String)
    case didTapContinuePhone(phone: String, formattedPhone: String)
}
