import AuthenticationServices
import StytchCore
import UIKit

final class DiscoveryViewController: BaseViewController<DiscoveryState, DiscoveryViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: NSLocalizedString("stytchDiscoveryTitle", value: "Select an organization to continue", comment: "")
    )

    init(state: DiscoveryState) {
        super.init(viewModel: DiscoveryViewModel(state: state))
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
