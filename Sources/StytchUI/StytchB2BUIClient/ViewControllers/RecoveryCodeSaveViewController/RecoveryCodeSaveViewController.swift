import AuthenticationServices
import StytchCore
import UIKit

final class RecoveryCodeSaveViewController: BaseViewController<RecoveryCodeSaveState, RecoveryCodeSaveViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_recovery_code_save_title
    )

    private let subtitleLabel: UILabel = .makeSubtitleLabel(
        text: LocalizationManager.stytch_b2b_recovery_code_save_subtitle
    )

    private lazy var saveButton: Button = .primary(
        title: LocalizationManager.stytch_b2b_recovery_code_save_button
    ) { [weak self] in
        self?.saveTapped()
    }

    private lazy var copyButton: Button = .primary(
        title: LocalizationManager.stytch_b2b_recovery_code_copy
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
            boldText: LocalizationManager.stytch_b2b_recovery_code_done,
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

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )

        hideBackButton()
    }

    @objc func doneTapped() {
        B2BAuthenticationManager.recoveryCodesSaved()
    }

    @objc func saveTapped() {
        presentShareSheet(text: B2BAuthenticationManager.recoveryCodes.joined(separator: "\n"))
    }

    @objc func copyTapped() {
        UIPasteboard.general.string = B2BAuthenticationManager.recoveryCodes.joined(separator: "\n")
        presentAlert(title: LocalizationManager.stytch_b2b_recovery_code_copied)
    }
}
