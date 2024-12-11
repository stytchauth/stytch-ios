import AuthenticationServices
import StytchCore
import UIKit

final class RecoveryCodeSaveViewController: BaseViewController<RecoveryCodeSaveState, RecoveryCodeSaveViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchRecoveryCodeSaveTitle", value: "Save your backup codes!", comment: "")
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: NSLocalizedString("stytchRecoveryCodeSaveSubtitle", value: "This is the only time you will be able to access and save your backup codes.", comment: "")
    )

    private lazy var saveButton: Button = .primary(
        title: NSLocalizedString("stytchRecoveryCodeSaveButton", value: "Save", comment: "")
    ) { [weak self] in
        self?.saveTapped()
    }

    private lazy var copyButton: Button = .primary(
        title: NSLocalizedString("stytchRecoveryCodeSaveCopy", value: "Copy", comment: "")
    ) { [weak self] in
        self?.copyTapped()
    }

    init(state: RecoveryCodeSaveState) {
        super.init(viewModel: RecoveryCodeSaveViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        let recoveryCodesListView = RecoveryCodesListView(codes: B2BAuthenticationManager.recoveryCodes)
        stackView.addArrangedSubview(recoveryCodesListView)

        let doneButton = Button.createTextButton(
            withPlainText: "",
            boldText: "Done",
            action: #selector(doneTapped),
            target: self
        )

        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(copyButton)
        stackView.addArrangedSubview(buttonStackView)

        stackView.addArrangedSubview(doneButton)

        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc func doneTapped() {
        B2BAuthenticationManager.recoveryCodesSaved()
    }

    @objc func saveTapped() {
        presentShareSheet(text: B2BAuthenticationManager.recoveryCodes.joined(separator: "\n"))
    }

    @objc func copyTapped() {
        UIPasteboard.general.string = B2BAuthenticationManager.recoveryCodes.joined(separator: "\n")
        presentAlert(title: "Recovery Codes Copied!")
    }
}
