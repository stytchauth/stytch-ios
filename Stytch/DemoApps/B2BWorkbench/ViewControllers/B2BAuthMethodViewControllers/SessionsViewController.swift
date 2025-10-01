import StytchCore
import UIKit

final class SessionsViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: .init { [weak self] _ in
        self?.authenticate()
    })

    lazy var revokeButton: UIButton = .init(title: "Revoke", primaryAction: .init { [weak self] _ in
        self?.revoke()
    })

    lazy var exchangeSessionButton: UIButton = .init(title: "Exchange", primaryAction: .init { [weak self] _ in
        self?.exchangeSession()
    })

    lazy var orgIdTextField: UITextField = .init(title: "Organization ID To Exchange Session With", primaryAction: .init { [weak self] _ in
        self?.exchangeSession()
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

        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(revokeButton)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(exchangeSessionButton)
        stackView.addArrangedSubview(orgIdTextField)

        orgIdTextField.delegate = self
    }

    func authenticate() {
        Task {
            do {
                let response = try await StytchB2BClient.sessions.authenticate(parameters: .init())
                presentAlertAndLogMessage(description: "authenticate session success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate session error", object: error)
            }
        }
    }

    func revoke() {
        Task {
            do {
                let response = try await StytchB2BClient.sessions.revoke()
                presentAlertAndLogMessage(description: "reovke session success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reovke session error", object: error)
            }
        }
    }

    func exchangeSession() {
        guard let organizationID = orgIdTextField.text else {
            return
        }
        Task {
            do {
                let parameters = StytchB2BClient.Sessions.ExchangeParameters(organizationID: organizationID)
                let response = try await StytchB2BClient.sessions.exchange(parameters: parameters)
                UserDefaults.standard.set(organizationID, forKey: orgIdDefaultsKey)
                orgIdTextField.text = ""
                presentAlertAndLogMessage(description: "exchange session success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "exchange session error", object: error)
            }
        }
    }
}

extension SessionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
