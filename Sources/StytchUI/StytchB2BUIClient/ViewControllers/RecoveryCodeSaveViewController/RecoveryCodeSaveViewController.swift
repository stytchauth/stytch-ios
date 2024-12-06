import AuthenticationServices
import StytchCore
import UIKit

final class RecoveryCodeSaveViewController: BaseViewController<RecoveryCodeSaveState, RecoveryCodeSaveViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchRecoveryCodeSaveTitle", value: "Save your backup codes!", comment: "")
    )

    init(state: RecoveryCodeSaveState) {
        super.init(viewModel: RecoveryCodeSaveViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}
