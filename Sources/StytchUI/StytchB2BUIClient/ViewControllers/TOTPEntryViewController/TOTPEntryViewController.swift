import AuthenticationServices
import StytchCore
import UIKit

final class TOTPEntryViewController: BaseViewController<TOTPEntryState, TOTPEntryViewModel> {
    let otpView = OTPCodeEntryView(frame: .zero)

    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchTOTPEntryTitle", value: "Enter verification code", comment: "")
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: NSLocalizedString("stytchTOTPEntrySubtitle", value: "Enter the 6-digit code from your authenticator app.", comment: "")
    )

    private let footerLabel: UILabel = .makeFooterLabel(
        text: NSLocalizedString("stytchTOTPEntryFooter", value: "If the verification code doesn’t work, go back to your authenticator app to get a new code.", comment: "")
    )

    init(state: TOTPEntryState) {
        super.init(viewModel: TOTPEntryViewModel(state: state))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let pasteboardText = UIPasteboard.general.string, pasteboardText.isNumber, pasteboardText.count == 6 {
            otpView.fillCode(code: pasteboardText)
        } else {
            otpView.startEditing()
        }
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingLarge

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        otpView.delegate = self
        stackView.addArrangedSubview(otpView)

        stackView.addArrangedSubview(footerLabel)

        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate([
            otpView.heightAnchor.constraint(equalToConstant: 50),
        ])

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    private func continueWithTOTP() {
        navigationController?.pushViewController(RecoveryCodeSaveViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
    }
}

extension TOTPEntryViewController: OTPCodeEntryViewDelegate {
    func didEnterOTPCode(_ code: String) {
        StytchB2BUIClient.startLoading()
        Task { [weak self] in
            do {
                try await self?.viewModel.authenticateTOTP(code: code)
                self?.continueWithTOTP()
                StytchB2BUIClient.stopLoading()
            } catch {
                self?.presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}
