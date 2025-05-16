import StytchCore
import UIKit

class CreateOrganizationViewController: BaseViewController<CreateOrganizationsState, CreateOrganizationsViewModel> {
    private lazy var createOrganizationButton: Button = .primary(
        title: LocalizationManager.stytch_b2b_create_organization_button
    ) { [weak self] in
        self?.createOrganization()
    }

    init(state: CreateOrganizationsState) {
        super.init(viewModel: CreateOrganizationsViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.backgroundColor = .background
        stackView.spacing = .spacingRegular

        let titleLabel: UILabel = .makeTitleLabel(
            text: LocalizationManager.stytch_b2b_create_organization_title
        )
        stackView.addArrangedSubview(titleLabel)

        stackView.addArrangedSubview(createOrganizationButton)

        let subtitleLabel: UILabel = .makeSubtitleLabel(
            text: LocalizationManager.stytch_b2b_create_organization_subtitle(value: MemberManager.emailAddress ?? "")
        )
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}
