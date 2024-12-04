import AuthenticationServices
import StytchCore
import UIKit

final class EmailConfirmationViewController: BaseViewController<EmailConfirmationState, EmailConfirmationViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchEmailConfirmationTitle", value: "Check your email!", comment: "")
    )

    init(state: EmailConfirmationState) {
        super.init(viewModel: EmailConfirmationViewModel(state: state))
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
