import StytchCore
import UIKit

protocol DiscoveredOrganizationsViewControllerDelegate: AnyObject {
    func didSelectDiscoveredOrganization(discoveredOrganization: StytchB2BClient.DiscoveredOrganization)
}

class DiscoveredOrganizationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]
    weak var delegate: DiscoveredOrganizationsViewControllerDelegate?

    init(discoveredOrganizations: [StytchB2BClient.DiscoveredOrganization]) {
        self.discoveredOrganizations = discoveredOrganizations
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(DiscoveredOrganizationTableViewCell.self, forCellReuseIdentifier: "DiscoveredOrganizationTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }

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
        cell.configure(with: discoveredOrganization, image: nil)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let discoveredOrganization = discoveredOrganizations[indexPath.row]
        delegate?.didSelectDiscoveredOrganization(discoveredOrganization: discoveredOrganization)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
