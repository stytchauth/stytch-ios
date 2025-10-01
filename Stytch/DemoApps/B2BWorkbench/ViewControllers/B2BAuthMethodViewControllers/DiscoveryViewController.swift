import StytchCore
import UIKit

final class DiscoveryViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var orgNameTextField: UITextField = .init(title: "Org Name", primaryAction: submitAction)

    lazy var discoverButton: UIButton = .init(title: "Discover", primaryAction: submitAction)

    lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.discover()
    }

    lazy var exchangeSessionButton: UIButton = .init(title: "Exchange Session", primaryAction: .init { [weak self] _ in
        self?.exchangeSession()
    })

    lazy var createOrgButton: UIButton = .init(title: "Create Org", primaryAction: .init { [weak self] _ in
        self?.createOrg()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Discovery"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(orgNameTextField)
        stackView.addArrangedSubview(discoverButton)
        stackView.addArrangedSubview(exchangeSessionButton)
        stackView.addArrangedSubview(createOrgButton)

        orgNameTextField.delegate = self
    }

    func discover() {
        Task {
            do {
                let response = try await StytchB2BClient.discovery.listOrganizations()
                presentAlertAndLogMessage(description: "list organizations success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "list organizations error", object: error)
            }
        }
    }

    func exchangeSession() {
        guard let orgId = organizationId else { return }

        Task {
            do {
                let response = try await StytchB2BClient.discovery.exchangeIntermediateSession(
                    parameters: .init(organizationId: .init(rawValue: orgId))
                )
                presentAlertAndLogMessage(description: "exchange session success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "exchange session error", object: error)
            }
        }
    }

    func createOrg() {
        guard let orgName = orgNameTextField.text, !orgName.isEmpty else { return }

        Task {
            do {
                let response = try await StytchB2BClient.discovery.createOrganization(
                    parameters: .init(organizationName: orgName)
                )
                presentAlertAndLogMessage(description: "create organization success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "create organization error", object: error)
            }
        }
    }
}

extension DiscoveryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
