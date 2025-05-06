import StytchCore
import UIKit

class NoDiscoveredOrganizationsViewController: BaseViewController<NoDiscoveredOrganizationsState, NoDiscoveredOrganizationsViewModel> {
    private lazy var tryDifferntEmailAddressButton: Button = .primary(
        title: LocalizationManager.stytch_b2b_no_discovered_organizations_try_differnt_email_address_button
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
            text: LocalizationManager.stytch_b2b_no_discovered_organizations_title(email: MemberManager.emailAddress ?? "")
        )
        stackView.addArrangedSubview(titleLabel)

        let subtitleLabel: UILabel = .makeSubtitleLabel(
            text: LocalizationManager.stytch_b2b_no_discovered_organizations_subtitle
        )
        stackView.addArrangedSubview(subtitleLabel)

        stackView.addArrangedSubview(tryDifferntEmailAddressButton)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    @objc func tryDifferntEmailAddressButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
