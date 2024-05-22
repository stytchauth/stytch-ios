import StytchCore
import UIKit

final class SessionsViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 8
        return view
    }()

    private lazy var authenticateButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Authenticate"
        return .init(configuration: configuration, primaryAction: authenticateAction)
    }()

    private lazy var revokeButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Revoke"
        return .init(configuration: configuration, primaryAction: revokeAction)
    }()

    private lazy var exchangeSessionButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Exchange"
        return .init(configuration: configuration, primaryAction: exchangeSessionsAction)
    }()

    private lazy var orgIdTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: exchangeSessionsAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Organization ID To Exchange Session With"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var authenticateAction: UIAction = .init { _ in
        Task {
            do {
                let response = try await StytchB2BClient.sessions.authenticate(parameters: .init())
                print("authenticateAction response: \(response)")
            } catch {
                print("authenticateAction error: \(error.errorInfo)")
            }
        }
    }

    private lazy var revokeAction: UIAction = .init { _ in
        Task {
            do {
                let response = try await StytchB2BClient.sessions.revoke()
                print("revokeAction response: \(response)")
            } catch {
                print("revokeAction error: \(error.errorInfo)")
            }
        }
    }

    private lazy var exchangeSessionsAction: UIAction = .init { _ in
        self.exchangeSession()
    }

    func exchangeSession() {
        guard let organizationID = orgIdTextField.text else {
            return
        }
        Task {
            do {
                let parameters = Sessions<B2BAuthenticateResponse>.ExchangeParameters(organizationID: organizationID)
                let response = try await StytchB2BClient.sessions.exchange(parameters: parameters)
                UserDefaults.standard.set(organizationID, forKey: Constants.orgIdDefaultsKey)
                orgIdTextField.text = ""
                presentAlertWithTitle(alertTitle: "Session Exchanged to org with id: \(organizationID)")
                print("exchangeAction response: \(response)")
            } catch {
                print("exchangeAction error: \(error.errorInfo)")
            }
        }
    }

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

        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(revokeButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(exchangeSessionButton)
        stackView.addArrangedSubview(orgIdTextField)
    }
}
