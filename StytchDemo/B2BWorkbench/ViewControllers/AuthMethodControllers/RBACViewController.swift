import StytchCore
import UIKit

final class RBACViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()

    lazy var isAuthorizedButton: UIButton = .init(title: "Is Authorized", primaryAction: .init { [weak self] _ in
        self?.isAuthorized()
    })

    lazy var allPermissionsButton: UIButton = .init(title: "All Permissions", primaryAction: .init { [weak self] _ in
        self?.allPermissions()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RBAC"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(isAuthorizedButton)
        stackView.addArrangedSubview(allPermissionsButton)
    }

    func isAuthorized() {
        Task {
            do {
                let response = try await StytchB2BClient.rbac.isAuthorized(resourceId: "", action: "")
                presentAlertAndLogMessage(description: "is authorized success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "is authorized error", object: error)
            }
        }
    }

    func allPermissions() {
        Task {
            do {
                let response = try await StytchB2BClient.rbac.allPermissions()
                presentAlertAndLogMessage(description: "all permissions success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "all permissions error", object: error)
            }
        }
    }
}
