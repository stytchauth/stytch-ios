import AuthenticationServices
import StytchCore
import UIKit

final class RecoveryCodeEntryViewController: BaseViewController<RecoveryCodeEntryState, RecoveryCodeEntryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchRecoveryCodeEntryTitle", value: "Enter backup code", comment: "")
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: NSLocalizedString("stytchRecoveryCodeEntrySubtitle", value: "Enter one of the backup codes you saved when setting up your authenticator app.", comment: "")
    )

    private lazy var recoveryCodeInput: RecoveryCodeInput = .init()

    private lazy var continueButton: Button = .primary(
        title: NSLocalizedString("stytch.pwContinueTitle", value: "Continue", comment: "")
    ) { [weak self] in
        self?.recoveryCodeEntered()
    }

    init(state: RecoveryCodeEntryState) {
        super.init(viewModel: RecoveryCodeEntryViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingLarge

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(recoveryCodeInput)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
        ])

        recoveryCodeInput.onReturn = { [weak self] isValid in
            if isValid == true {
                self?.recoveryCodeEntered()
            }
        }
    }

    @objc func recoveryCodeEntered() {
        guard let recoveryCode = recoveryCodeInput.text else {
            return
        }

        StytchB2BUIClient.startLoading()
        Task {
            do {
                try await viewModel.recover(recoveryCode: recoveryCode)
                StytchB2BUIClient.stopLoading()
            } catch {
                presentErrorAlert(error: error)
                StytchB2BUIClient.stopLoading()
            }
        }
    }
}
