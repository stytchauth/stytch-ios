import StytchCore
import UIKit

final class ViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var consumerSessionsButton: UIButton = .init(title: "Consumer Sessions", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(StytchConsumerSessionsViewController(), animated: true)
    })

    lazy var b2bSessionsButton: UIButton = .init(title: "B2B Sessions", primaryAction: .init { [weak self] _ in
        self?.navigationController?.pushViewController(StytchB2BSessionsViewController(), animated: true)
    })

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sessions"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(consumerSessionsButton)
        stackView.addArrangedSubview(b2bSessionsButton)
    }
}

var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}
