import StytchCore
import UIKit

final class SSOViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var connectionIdTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: startAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Connection Id"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var redirectUrlTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: startAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Redirect URL"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
        return textField
    }()

    private lazy var startAction: UIAction = .init { [weak self] _ in
        self?.start()
    }

    private lazy var startButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Start"
        return .init(configuration: configuration, primaryAction: startAction)
    }()

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

    private func start() {
        guard let connectionId = connectionIdTextField.text, !connectionId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.flatMap(URL.init(string:)) else { return }

        UserDefaults.standard.set(redirectUrl.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                let (token, _) = try await StytchB2BClient.sso.start(parameters: .init(connectionId: connectionId, loginRedirectUrl: redirectUrl, signupRedirectUrl: redirectUrl))
                let response = try await StytchB2BClient.sso.authenticate(parameters: .init(token: token))
                print(response)
            } catch {
                print("sso error: \(error.errorInfo)")
            }
        }
    }
}
