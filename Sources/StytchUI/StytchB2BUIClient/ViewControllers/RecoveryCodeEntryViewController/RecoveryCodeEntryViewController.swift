import AuthenticationServices
import StytchCore
import UIKit

final class RecoveryCodeEntryViewController: BaseViewController<RecoveryCodeEntryState, RecoveryCodeEntryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchRecoveryCodeEntryTitle", value: "Enter backup code", comment: "")
    )

    init(state: RecoveryCodeEntryState) {
        super.init(viewModel: RecoveryCodeEntryViewModel(state: state))
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
