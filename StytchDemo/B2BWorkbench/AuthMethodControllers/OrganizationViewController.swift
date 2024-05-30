import StytchCore
import UIKit

final class OrganizationViewController: UIViewController {
    let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    lazy var getButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Get"
        return .init(configuration: configuration, primaryAction: getAction)
    }()

    lazy var getSyncButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Get Sync"
        return .init(configuration: configuration, primaryAction: getSyncAction)
    }()

    lazy var getAction: UIAction = .init { _ in
        Task {
            do {
                let resp = try await StytchB2BClient.organization.get()
                print(resp)
            } catch {
                print("get organization action error: \(error.errorInfo)")
            }
        }
    }

    lazy var getSyncAction: UIAction = .init { _ in
        print(StytchB2BClient.organization.getSync())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Organization"

        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(getButton)
        stackView.addArrangedSubview(getSyncButton)
    }
}
