import StytchCore
import UIKit

protocol MFAMethodSelectionViewControllerDelegate: AnyObject {
    func didSelectMFAMethod(mfaMethod: StytchB2BClient.MfaMethod)
}

class MFAMethodSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let mfaMethods: [StytchB2BClient.MfaMethod]
    weak var delegate: MFAMethodSelectionViewControllerDelegate?

    init(mfaMethods: [StytchB2BClient.MfaMethod]) {
        self.mfaMethods = mfaMethods
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

        tableView.register(MFAEnrollmentSelectionTableViewCell.self, forCellReuseIdentifier: "MFAEnrollmentSelectionTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        mfaMethods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MFAEnrollmentSelectionTableViewCell", for: indexPath) as? MFAEnrollmentSelectionTableViewCell else {
            return UITableViewCell()
        }

        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        let mfaMethod = mfaMethods[indexPath.row]
        cell.configure(with: mfaMethod, image: nil)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mfaMethod = mfaMethods[indexPath.row]
        delegate?.didSelectMFAMethod(mfaMethod: mfaMethod)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
