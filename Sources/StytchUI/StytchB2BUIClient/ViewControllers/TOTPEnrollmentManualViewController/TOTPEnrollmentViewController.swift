import AuthenticationServices
import StytchCore
import UIKit

final class TOTPEnrollmentViewController: BaseViewController<TOTPEnrollmentState, TOTPEnrollmentViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchTOTPEnrollmentTitle", value: "Copy the code below to link your authenticator app", comment: "")
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: NSLocalizedString("stytchTOTPEnrollmentSubtitle", value: "Enter the key below into your authenticator app. If you don’t have an authenticator app, you’ll need to install one first.", comment: "")
    )

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in
        self?.continueWithTOTP()
    }

    init(state: TOTPEnrollmentState) {
        super.init(viewModel: TOTPEnrollmentViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        let totpSecretView = TOTPSecretView(secret: viewModel.state.secret)
        totpSecretView.delegate = self
        stackView.addArrangedSubview(totpSecretView)

        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    private func continueWithTOTP() {
        navigationController?.pushViewController(TOTPEntryViewController(state: .init(configuration: viewModel.state.configuration)), animated: true)
    }
}

extension TOTPEnrollmentViewController: TOTPSecretViewDelegate {
    func didCopyTOTPSecret() {
        presentAlert(title: "Secret Copied!", message: nil)
    }
}
