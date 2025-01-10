import StytchCore
import UIKit

protocol SelectionViewControllerDelegate: AnyObject {
    func didSelectCell(label: String)
}

class SelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let labels: [String]
    weak var delegate: SelectionViewControllerDelegate?

    init(labels: [String]) {
        self.labels = labels
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        tableView.backgroundColor = .background

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(SelectionTableViewCell.self, forCellReuseIdentifier: "SelectionTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        labels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionTableViewCell", for: indexPath) as? SelectionTableViewCell else {
            return UITableViewCell()
        }

        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.configure(with: labels[indexPath.row])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCell(label: labels[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
