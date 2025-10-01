import StytchCore
import UIKit

final class ConsumerOAuthViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var startButton: UIButton = .init(title: "Start", primaryAction: .init { [weak self] _ in
        self?.start()
    })

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: .init { [weak self] _ in
        self?.authenticate()
    })

    var token: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "OAuth"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(authenticateButton)
    }

    func start() {
        let configuraiton = StytchClient.OAuth.ThirdParty.WebAuthenticationConfiguration(
            loginRedirectUrl: redirectUrl,
            signupRedirectUrl: redirectUrl,
            customScopes: nil,
            providerParams: nil
        )

        Task {
            do {
                let (token, url) = try await StytchClient.oauth.google.start(configuration: configuraiton)
                self.token = token
                presentAlertAndLogMessage(description: "oauth start success!", object: (token, url))
            } catch {
                presentAlertAndLogMessage(description: "oauth start error", object: error)
            }
        }
    }

    func authenticate() {
        guard let token = token else {
            return
        }

        Task {
            do {
                let response = try await StytchClient.oauth.authenticate(
                    parameters: .init(
                        token: token
                    )
                )
                presentAlertAndLogMessage(description: "oauth authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "oauth authenticate error", object: error)
            }
        }
    }
}
