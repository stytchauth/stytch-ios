import AuthenticationServices
import StytchCore
import UIKit

final class SMSOTPEnrollmentViewController: BaseViewController<SMSOTPEnrollmentState, SMSOTPEnrollmentViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchSMSOTPEnrollmentTitle", value: "Enter your phone number to set up Multi-Factor Authentication", comment: "")
    )

    init(state: SMSOTPEnrollmentState) {
        super.init(viewModel: SMSOTPEnrollmentViewModel(state: state))
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
