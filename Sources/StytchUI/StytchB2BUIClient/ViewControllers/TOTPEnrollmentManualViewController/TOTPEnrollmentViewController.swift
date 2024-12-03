import AuthenticationServices
import StytchCore
import UIKit

final class TOTPEnrollmentViewController: BaseViewController<TOTPEnrollmentState, TOTPEnrollmentViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchSMSOTPEnrollmentTitle", value: "Copy the code below to link your authenticator app", comment: "")
    )

    init(state: TOTPEnrollmentState) {
        super.init(viewModel: TOTPEnrollmentViewModel(state: state))
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
