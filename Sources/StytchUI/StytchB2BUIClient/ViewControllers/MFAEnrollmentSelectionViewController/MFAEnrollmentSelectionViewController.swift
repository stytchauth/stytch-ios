import AuthenticationServices
import StytchCore
import UIKit

final class MFAEnrollmentSelectionViewController: BaseViewController<MFAEnrollmentSelectionState, MFAEnrollmentSelectionViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchMfaEnrollmentTitle", value: "Set up Multi-Factor Authentication", comment: "")
    )

    init(state: MFAEnrollmentSelectionState) {
        super.init(viewModel: MFAEnrollmentSelectionViewModel(state: state))
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
