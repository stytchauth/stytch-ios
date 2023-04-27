import StytchCore
import UIKit

final class DiscoveryViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var intermediateSessionTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Intermediate Session Token"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var orgIdTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Org Id"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var orgNameTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Org Name"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.discover()
    }

    private lazy var discoverButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Discover"
        return .init(configuration: configuration, primaryAction: submitAction)
    }()

    private lazy var exchangeSessionButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Exchange Session"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.exchangeSession()
        })
    }()

    private lazy var createOrgButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Create Org"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.createOrg()
        })
    }()

    private let defaults: UserDefaults = .standard

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

        stackView.addArrangedSubview(intermediateSessionTextField)
        stackView.addArrangedSubview(orgIdTextField)
        stackView.addArrangedSubview(orgNameTextField)
        stackView.addArrangedSubview(discoverButton)
        stackView.addArrangedSubview(exchangeSessionButton)
        stackView.addArrangedSubview(createOrgButton)
    }

    private func discover() {
        guard let token = intermediateSessionTextField.text, !token.isEmpty else { return }

        Task {
            do {
                let response = try await StytchB2BClient.discovery.listOrganizations(
                    parameters: .init(intermediateSessionToken: token)
                )
                print(response)
            } catch {
                print(error)
            }
        }
    }

    private func exchangeSession() {
        guard let token = intermediateSessionTextField.text, !token.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }


        Task {
            do {
                let response = try await StytchB2BClient.discovery.exchangeIntermediateSession(
                    parameters: .init(intermediateSessionToken: token, organizationId: .init(rawValue: orgId))
                )
                print(response)
            } catch {
                print(error)
            }
        }
    }

    private func createOrg() {
        guard let token = intermediateSessionTextField.text, !token.isEmpty else { return }
        guard let orgName = orgNameTextField.text, !orgName.isEmpty else { return }

        Task {
            do {
                let response = try await StytchB2BClient.discovery.createOrganization(
                    parameters: .init(intermediateSessionToken: token, organizationName: orgName)
                )
                print(response)
            } catch {
                print(error)
            }
        }
    }
}
