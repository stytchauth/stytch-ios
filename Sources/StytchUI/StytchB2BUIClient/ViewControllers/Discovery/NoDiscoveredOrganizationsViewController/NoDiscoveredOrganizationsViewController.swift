import StytchCore
import UIKit

class NoDiscoveredOrganizationsViewController: BaseViewController<NoDiscoveredOrganizationsState, NoDiscoveredOrganizationsViewModel> {
    private lazy var tryDifferntEmailAddressButton: Button = .primary(
        title: NSLocalizedString("stytchNoDiscoveredOrganizationsTryDifferntEmailAddressButtonTitle", value: "Try a different email address", comment: "")
    ) { [weak self] in
        self?.tryDifferntEmailAddressButtonTapped()
    }

    init(state: NoDiscoveredOrganizationsState) {
        super.init(viewModel: NoDiscoveredOrganizationsViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.backgroundColor = .background
        stackView.spacing = .spacingRegular

        let titleLabel: UILabel = .makeTitleLabel(
            text: .localizedStringWithFormat(
                NSLocalizedString("stytchNoDiscoveredOrganizationsTitle", value: "%@ does not belong to any organizations.", comment: ""),
                MemberManager.emailAddress ?? ""
            )
        )
        stackView.addArrangedSubview(titleLabel)

        let subtitleLabel: UILabel = .makeSubtitleLabel(
            text: NSLocalizedString("stytchNoDiscoveredOrganizationsSubtitle", value: "Make sure your email address is correct. Otherwise, you might need to be invited by your admin.", comment: "")
        )
        stackView.addArrangedSubview(subtitleLabel)

        stackView.addArrangedSubview(tryDifferntEmailAddressButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc func tryDifferntEmailAddressButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
