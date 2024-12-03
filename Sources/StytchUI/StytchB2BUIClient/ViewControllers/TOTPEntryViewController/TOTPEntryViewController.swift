import AuthenticationServices
import StytchCore
import UIKit

final class TOTPEntryViewController: BaseViewController<TOTPEntryState, TOTPEntryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchTOTPEntryTitle", value: "Enter verification code", comment: "")
    )

    init(state: TOTPEntryState) {
        super.init(viewModel: TOTPEntryViewModel(state: state))
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
