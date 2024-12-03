import AuthenticationServices
import StytchCore
import UIKit

final class SMSOTPEntryViewController: BaseViewController<SMSOTPEntryState, SMSOTPEntryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchSMSOTPEntryTitle", value: "Enter passcode", comment: "")
    )

    init(state: SMSOTPEntryState) {
        super.init(viewModel: SMSOTPEntryViewModel(state: state))
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
