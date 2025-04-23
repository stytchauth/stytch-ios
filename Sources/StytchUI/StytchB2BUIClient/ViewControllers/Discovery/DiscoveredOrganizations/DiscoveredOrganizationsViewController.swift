import StytchCore
import UIKit

class DiscoveredOrganizationsViewController: BaseViewController<DiscoveredOrganizationsState, DiscoveredOrganizationsViewModel> {
    private let titleLabel: UILabel = .makeTitleLabel(
        text: LocalizationManager.stytch_b2b_discovered_organizations_title
    )

    private lazy var createOrganizationButton: Button = .primary(
        title: LocalizationManager.stytch_b2b_create_organization_button
    ) { [weak self] in
        self?.createOrganization()
    }

    private let tableView = UITableView()
    private let discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]

    init(state: DiscoveredOrganizationsState, discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]) {
        self.discoveredOrganizations = discoveredOrganizations
        super.init(viewModel: DiscoveredOrganizationsViewModel(state: state))
    }

    override func configureView() {
        super.configureView()

        view.backgroundColor = .background
        stackView.spacing = .spacingRegular

        stackView.addArrangedSubview(titleLabel)
        configureTableView()

        attachStackView(within: view)

        NSLayoutConstraint.activate(
            stackView.arrangedSubviews.map { $0.widthAnchor.constraint(equalTo: stackView.widthAnchor) }
        )
    }

    func configureTableView() {
        tableView.backgroundColor = .background
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(DiscoveredOrganizationTableViewCell.self, forCellReuseIdentifier: "DiscoveredOrganizationTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false

        stackView.addArrangedSubview(tableView)

        if viewModel.state.configuration.allowsUserCreateOrganizations {
            stackView.addArrangedSubview(createOrganizationButton)
        }
    }
}

extension DiscoveredOrganizationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        discoveredOrganizations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredOrganizationTableViewCell", for: indexPath) as? DiscoveredOrganizationTableViewCell else {
            return UITableViewCell()
        }

        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        let discoveredOrganization = discoveredOrganizations[indexPath.row]
        cell.configure(with: discoveredOrganization)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let discoveredOrganization = discoveredOrganizations[indexPath.row]
        selectDiscoveredOrganization(
            configuration: viewModel.state.configuration,
            discoveredOrganization: discoveredOrganization
        )
    }
}
