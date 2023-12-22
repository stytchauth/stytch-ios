import PhoneNumberKit
import StytchCore
import UIKit

final class AuthInputViewController: BaseViewController<AuthInputState, AuthInputViewModel> {
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

    init(state: AuthInputState) {
        super.init(viewModel: AuthInputViewModel(state: state))
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
            let countryPickerViewController = CountryCodePickerViewController(phoneNumberKit: phoneNumberInput.phoneNumberKit)
            countryPickerViewController.delegate = self.phoneNumberInput
            let navigationController = UINavigationController(rootViewController: countryPickerViewController)
            present(navigationController, animated: true)
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
            Task {
                do {
                    if let email = self.emailInput.text {
                        if viewModel.state.config.magicLink != nil, viewModel.state.config.password != nil {
                            let intent = try await viewModel.getUserIntent(email: email)
                            if let intent = intent {
                                DispatchQueue.main.async {
                                    self.launchPassword(intent: intent, email: email, magicLinksEnabled: self.viewModel.state.config.magicLink != nil)
                                }
                            } else {
                                try await viewModel.resetPassword(email: email)
                                DispatchQueue.main.async {
                                    self.launchCheckYourEmailResetReturning(email: email)
                                }
                            }
                        } else if let magicLink = viewModel.state.config.magicLink {
                            try await viewModel.sendMagicLink(email: email)
                            DispatchQueue.main.async {
                                self.launchCheckYourEmail(email: email)
                            }
                        }
                    }
                } catch {}
            }
        case .phone:
            Task {
                do {
                    if let phone = phoneNumberInput.phoneNumberE164, let formattedPhone = phoneNumberInput.formattedPhoneNumber {
                        let (result, expiry) = try await viewModel.continueWithPhone(
                            phone: phone,
                            formattedPhone: formattedPhone
                        )
                        DispatchQueue.main.async {
                            self.launchOTP(phone: phone, formattedPhone: formattedPhone, result: result, expiry: expiry)
                        }
                    }

                } catch {}
            }
        }
    }
}

extension AuthInputViewController: AuthInputViewModelDelegate {
    func launchCheckYourEmailResetReturning(email: String) {
        let controller = ActionableInfoViewController(
            state: .checkYourEmailResetReturning(config: viewModel.state.config, email: email, retryAction: {

            })
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchPassword(intent: PasswordState.Intent, email: String, magicLinksEnabled: Bool) {
        let controller = PasswordViewController(
            state: .init(config: viewModel.state.config, intent: intent, email: email, magicLinksEnabled: magicLinksEnabled)
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchCheckYourEmail(email: String) {
        let controller = ActionableInfoViewController(
            state: .checkYourEmail(config: viewModel.state.config, email: email, retryAction: {

            })
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchOTP(phone: String, formattedPhone: String, result: StytchClient.OTP.OTPResponse, expiry: Date) {
        let controller = OTPCodeViewController(
            state: .init(
                config: viewModel.state.config,
                phoneNumberE164: phone,
                formattedPhoneNumber: formattedPhone,
                methodId: result.methodId,
                codeExpiry: expiry
            )
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}
