import StytchCore
import UIKit

final class SSOViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()

    lazy var connectionIdTextField: UITextField = .init(title: "Connection Id", primaryAction: startAction)

    lazy var redirectUrlTextField: UITextField = .init(title: "Redirect URL", primaryAction: startAction, keyboardType: .URL)

    lazy var startButton: UIButton = .init(title: "Start", primaryAction: startAction)

    lazy var startAction: UIAction = .init { [weak self] _ in
        self?.start()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SSO"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(connectionIdTextField)
        stackView.addArrangedSubview(redirectUrlTextField)
        stackView.addArrangedSubview(startButton)

        redirectUrlTextField.text = UserDefaults.standard.string(forKey: Constants.redirectUrlDefaultsKey) ?? "b2bworkbench://auth"
    }

    func start() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.flatMap(URL.init(string:)) else { return }

        UserDefaults.standard.set(redirectUrl.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                let (token, _) = try await StytchB2BClient.sso.start(
                    parameters: .init(
                        connectionId: connectionId,
                        loginRedirectUrl: redirectUrl,
                        signupRedirectUrl: redirectUrl
                    )
                )
                let response = try await StytchB2BClient.sso.authenticate(
                    parameters: .init(token: token)
                )
                presentAlertAndLogMessage(description: "sso start-authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "sso start-authenticate error", object: error)
            }
        }
    }
}
