import AuthenticationServices
import StytchCore
import UIKit

final class TOTPEntryViewController: BaseViewController<TOTPEntryState, TOTPEntryViewModel> {
    let otpView = OTPCodeEntryView(frame: .zero)

    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_totp_entry_title
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: LocalizationManager.stytch_b2b_totp_entry_subtitle
    )

    private let footerLabel: UILabel = .makeFooterLabel(
        text: LocalizationManager.stytch_b2b_totp_entry_footer
    )

    init(state: TOTPEntryState) {
        super.init(viewModel: TOTPEntryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingLarge

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(otpView)

        // If the totpResponse is not nil, it means we are actively enrolling in TOTP, and we cannot use a recovery code yet.
        if B2BAuthenticationManager.totpResponse != nil {
            stackView.addArrangedSubview(footerLabel)
        } else {
            let useRecoveryCodeButton = Button.createTextButton(
                withPlainText: LocalizationManager.stytch_b2b_totp_cant_access_authenticator_app,
                boldText: LocalizationManager.stytch_b2b_totp_use_backup_code,
                action: #selector(useRecoveryCodeButtonTapped),
                target: self
            )
            useRecoveryCodeButton.contentHorizontalAlignment = .leading
            stackView.addArrangedSubview(useRecoveryCodeButton)
        }

        stackView.addArrangedSubview(SpacerView())
        otpView.delegate = self

        attachStackViewToScrollView()

        NSLayoutConstraint.activate([
            otpView.heightAnchor.constraint(equalToConstant: 50),
        ])

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        if let totpRegistrationId = MemberManager.member?.totpRegistrationId, totpRegistrationId.isEmpty == false {
            hideBackButton()
        }
    }

    private func continueWithTOTP() {
        // We only want to show the RecoveryCodeSaveViewController if we have a totp response with recovery codes
        if B2BAuthenticationManager.totpResponse != nil {
            navigationController?.pushViewController(RecoveryCodeSaveViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
        }
    }

    @objc func useRecoveryCodeButtonTapped() {
        navigationController?.pushViewController(RecoveryCodeEntryViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
    }
}

extension TOTPEntryViewController: OTPCodeEntryViewDelegate {
    func didEnterOTPCode(_ code: String) {
        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await viewModel.authenticateTOTP(code: code)
                StytchB2BUIClient.stopLoading()
                continueWithTOTP()
            } catch {
                otpView.clear()
                ErrorPublisher.publishError(error)
                presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}
