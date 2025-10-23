import AuthenticationServices
import PhoneNumberKit
import StytchCore
import UIKit

final class SMSOTPEnrollmentViewController: BaseViewController<SMSOTPEnrollmentState, SMSOTPEnrollmentViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_sms_otp_enrollment_title
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: LocalizationManager.stytch_b2b_sms_otp_enrollment_subtitle
    )

    private let phoneNumberInput: PhoneNumberInput = .init()

    private lazy var continueButton: Button = .primary(
        title: LocalizationManager.stytch_continue_button
    ) { [weak self] in
        self?.continueWithSMSOTP()
    }

    init(state: SMSOTPEnrollmentState) {
        super.init(viewModel: SMSOTPEnrollmentViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(phoneNumberInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

        setupPhoneNumberInput(input: phoneNumberInput)
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

        phoneNumberInput.onReturn = { [weak self] isValid in
            if isValid == true {
                self?.continueWithSMSOTP()
            }
        }
    }

    @objc func continueWithSMSOTP() {
        if let phoneNumberE164 = phoneNumberInput.phoneNumberE164 {
            MemberManager.updateMemberPhoneNumber(phoneNumberE164)
            StytchB2BUIClient.startLoading()
            Task {
                do {
                    try await AuthenticationOperations.smsSendOTP(
                        configuration: viewModel.state.configuration,
                        phoneNumberE164: phoneNumberE164
                    )
                    StytchB2BUIClient.stopLoading()
                    navigationController?.pushViewController(SMSOTPEntryViewController(state: .init(configuration: viewModel.state.configuration, didSendCode: true)), animated: true)
                } catch {
                    StytchB2BUIClient.stopLoading()
                    ErrorPublisher.publishError(error)
                    presentErrorAlert(error: error)
                }
            }
        }
    }
}
