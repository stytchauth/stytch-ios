import StytchCore
import UIKit

class CreateOrganizationViewController: BaseViewController<CreateOrganizationsState, CreateOrganizationsViewModel> {
    private lazy var createOrganizationButton: Button = .primary(
        title: NSLocalizedString("stytchCreateOrganizationCreateOrganizationButton", value: "Create an organization", comment: "")
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
            text: NSLocalizedString("stytchCreateOrganizationTitle", value: "Create an organization to get started", comment: "")
        )
        stackView.addArrangedSubview(titleLabel)

        stackView.addArrangedSubview(createOrganizationButton)

        let subtitleLabel: UILabel = .makeSubtitleLabel(
            text: .localizedStringWithFormat(
                NSLocalizedString("stytchCreateOrganizationSubtitle", value: "%@ does not have an account. Think this is a mistake? Try a different email address, or contact your admin.", comment: ""),
                MemberManager.emailAddress ?? ""
            )
        )
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(SpacerView())

        attachStackViewToScrollView()

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }
}
