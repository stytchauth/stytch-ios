import PhoneNumberKit
import StytchCore
import UIKit

final class AuthInputViewController: BaseViewController<AuthInputState, AuthInputViewModel> {
    private enum Input {
        case email
        case phone
        case whatsapp
    }

    private lazy var segmentedControl: UISegmentedControl? = {
        guard inputs.count > 1 else { return nil }
        let segmentedControl = UISegmentedControl()
        for input in inputs {
            switch input {
            case .email:
                segmentedControl.insertSegment(
                    withTitle: LocalizationManager.stytch_b2c_home_email,
                    at: segmentedControl.numberOfSegments,
                    animated: false
                )
            case .phone:
                segmentedControl.insertSegment(
                    withTitle: LocalizationManager.stytch_b2c_home_text,
                    at: segmentedControl.numberOfSegments,
                    animated: false
                )
            case .whatsapp:
                segmentedControl.insertSegment(
                    withTitle: LocalizationManager.stytch_b2c_home_whatsApp,
                    at: segmentedControl.numberOfSegments,
                    animated: false
                )
            }
        }

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.accessibilityLabel = "emailTextSegmentedControl"
        return segmentedControl
    }()

    private lazy var inputs: [Input] = {
        var inputs: [Input] = []

        if viewModel.state.config.supportsOTP == true, let otpMethods = viewModel.state.config.otpOptions?.methods {
            for method in otpMethods {
                switch method {
                case .sms:
                    inputs.append(.phone)
                case .email:
                    inputs.append(.email)
                case .whatsapp:
                    inputs.append(.whatsapp)
                }
            }
        }

        if inputs.contains(.email) == false {
            if viewModel.state.config.supportsEmailMagicLinks || viewModel.state.config.supportsPasswords {
                inputs.append(.email)
            }
        }

        return inputs
    }()

    private let phoneNumberInput: PhoneNumberInput = .init()

    private let emailInput: EmailInput = .init()

    private let whatsAppInput: PhoneNumberInput = .init()

    private lazy var continueButton: UIButton = {
        let button = Button.primary(
            title: LocalizationManager.stytch_continue_button
        ) { [weak self] in
            self?.didTapContinue()
        }
        button.isEnabled = false
        return button
    }()

    private lazy var activeInput: Input = {
        var input: Input = .whatsapp
        if inputs.contains(.email) {
            input = .email
        } else if inputs.contains(.phone) {
            input = .phone
        }
        self.hideInputs(for: input)
        return input
    }() {
        didSet {
            self.hideInputs(for: activeInput)
        }
    }

    private var isCurrentInputValid: Bool {
        switch activeInput {
        case .email:
            return emailInput.isValid
        case .phone:
            return phoneNumberInput.isValid
        case .whatsapp:
            return whatsAppInput.isValid
        }
    }

    init(state: AuthInputState) {
        super.init(viewModel: AuthInputViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.layoutMargins = .zero

        if let segmentedControl = segmentedControl {
            segmentedControl.addTarget(self, action: #selector(segmentDidUpdate(sender:)), for: .primaryActionTriggered)
            stackView.addArrangedSubview(segmentedControl)
        }

        if inputs.contains(.email) {
            stackView.addArrangedSubview(emailInput)
        }
        if inputs.contains(.phone) {
            stackView.addArrangedSubview(phoneNumberInput)
        }
        if inputs.contains(.whatsapp) {
            stackView.addArrangedSubview(whatsAppInput)
        }
        stackView.addArrangedSubview(continueButton)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        setupPhoneNumberInput(input: phoneNumberInput)
        setupPhoneNumberInput(input: whatsAppInput)
        setupEmailInput(input: emailInput)

        hideInputs(for: activeInput)

        if !inputs.isEmpty {
            activeInput = inputs[0]
        }
    }

    private func hideInputs(for input: Input) {
        phoneNumberInput.isHidden = input != .phone
        emailInput.isHidden = input != .email
        whatsAppInput.isHidden = input != .whatsapp
    }

    private func setupPhoneNumberInput(input: PhoneNumberInput) {
        input.onButtonPressed = { [weak self] _ in
            guard let self else { return }
            let countryPickerViewController = CountryCodePickerViewController(utility: input.phoneNumberUtility, options: .init())
            countryPickerViewController.delegate = input
            let navigationController = UINavigationController(rootViewController: countryPickerViewController)
            present(navigationController, animated: true)
        }

        input.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (input.hasBeenValid, isValid) {
            case (_, true):
                input.setFeedback(nil)
            case (true, false):
                input.setFeedback(.error(LocalizationManager.stytch_invalid_phone_number))
            case (false, false):
                break
            }
        }
    }

    private func setupEmailInput(input: EmailInput) {
        input.onTextChanged = { [weak self] isValid in
            guard let self else { return }

            self.continueButton.isEnabled = isValid

            switch (input.hasBeenValid, isValid) {
            case (_, true):
                input.setFeedback(nil)
            case (true, false):
                input.setFeedback(.error(LocalizationManager.stytch_invalid_email))
            case (false, false):
                break
            }
        }
    }

    @objc private func segmentDidUpdate(sender: UISegmentedControl) {
        activeInput = inputs[sender.selectedSegmentIndex]
        continueButton.isEnabled = isCurrentInputValid
    }

    private func launchMagicLinkPassword(email: String) async throws {
        let intent = try await viewModel.getUserIntent(email: email)
        if let intent = intent {
            DispatchQueue.main.async {
                self.launchPassword(intent: intent, email: email, magicLinksEnabled: self.viewModel.state.config.supportsEmailMagicLinks)
            }
        } else {
            try await viewModel.resetPassword(email: email)
            DispatchQueue.main.async {
                self.launchCheckYourEmailResetReturning(email: email)
            }
        }
    }

    private func launchMagicLinkOnly(email: String) async throws {
        try await viewModel.sendMagicLink(email: email)
        DispatchQueue.main.async {
            self.launchCheckYourEmail(email: email)
        }
    }

    private func launchPasswordOnly(email: String) async throws {
        let intent = try await viewModel.getUserIntent(email: email)
        if let intent = intent {
            DispatchQueue.main.async {
                self.launchPassword(intent: intent, email: email, magicLinksEnabled: false)
            }
        }
    }

    @objc private func didTapContinue() {
        StytchUIClient.startLoading()
        Task {
            do {
                switch activeInput {
                case .email:
                    if let email = self.emailInput.text {
                        if viewModel.state.config.supportsEmailMagicLinks, viewModel.state.config.supportsPasswords {
                            try await launchMagicLinkPassword(email: email)
                        } else if viewModel.state.config.supportsEmailMagicLinks {
                            try await launchMagicLinkOnly(email: email)
                        } else if viewModel.state.config.supportsOTP {
                            let (result, expiry) = try await viewModel.continueWithEmail(email: email)
                            DispatchQueue.main.async {
                                self.launchOTP(input: email, formattedInput: email, otpMethod: .email, result: result, expiry: expiry)
                            }
                        } else {
                            try await launchPasswordOnly(email: email)
                        }

                        StytchUIClient.stopLoading()
                    }
                case .phone:
                    if let phone = phoneNumberInput.phoneNumberE164, let formattedPhone = phoneNumberInput.formattedPhoneNumber {
                        let (result, expiry) = try await viewModel.continueWithPhone(
                            phone: phone,
                            formattedPhone: formattedPhone
                        )
                        DispatchQueue.main.async {
                            self.launchOTP(input: phone, formattedInput: formattedPhone, otpMethod: .sms, result: result, expiry: expiry)
                        }

                        StytchUIClient.stopLoading()
                    }
                case .whatsapp:
                    if let phone = whatsAppInput.phoneNumberE164, let formattedPhone = whatsAppInput.formattedPhoneNumber {
                        let (result, expiry) = try await viewModel.continueWithWhatsApp(
                            phone: phone,
                            formattedPhone: formattedPhone
                        )
                        DispatchQueue.main.async {
                            self.launchOTP(input: phone, formattedInput: formattedPhone, otpMethod: .whatsapp, result: result, expiry: expiry)
                        }

                        StytchUIClient.stopLoading()
                    }
                }
            } catch {
                StytchUIClient.stopLoading()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
            }
        }
    }
}

protocol AuthInputViewModelDelegate: AnyObject {
    func launchCheckYourEmailResetReturning(email: String)
    func launchPassword(intent: PasswordState.Intent, email: String, magicLinksEnabled: Bool)
    func launchCheckYourEmail(email: String)
    func launchOTP(input: String, formattedInput: String, otpMethod: StytchUIClient.OTPMethod, result: StytchClient.OTP.OTPResponse, expiry: Date)
}

extension AuthInputViewController: AuthInputViewModelDelegate {
    func launchCheckYourEmailResetReturning(email: String) {
        let controller = EmailConfirmationViewController(
            state: .checkYourEmailResetReturning(config: viewModel.state.config, email: email) {
                try await self.viewModel.sendMagicLink(email: email)
            }
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
        let controller = EmailConfirmationViewController(
            state: .checkYourEmail(config: viewModel.state.config, email: email) {
                try await self.viewModel.sendMagicLink(email: email)
            }
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    func launchOTP(input: String, formattedInput: String, otpMethod: StytchUIClient.OTPMethod, result: StytchClient.OTP.OTPResponse, expiry: Date) {
        let controller = OTPCodeViewController(
            state: .init(
                config: viewModel.state.config,
                otpMethod: otpMethod,
                input: input,
                formattedInput: formattedInput,
                methodId: result.methodId,
                codeExpiry: expiry,
                passwordsEnabled: viewModel.state.config.supportsPasswords
            )
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}
