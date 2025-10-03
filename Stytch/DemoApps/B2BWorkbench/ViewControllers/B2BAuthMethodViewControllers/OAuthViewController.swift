import StytchCore
import UIKit

final class OAuthViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var startButton: UIButton = .init(title: "Start", primaryAction: .init { [weak self] _ in
        self?.start()
    })

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: .init { [weak self] _ in
        self?.authenticate()
    })

    lazy var discoveryStartButton: UIButton = .init(title: "Discovery Start", primaryAction: .init { [weak self] _ in
        self?.discoveryStart()
    })

    lazy var discoveryAuthenticateButton: UIButton = .init(title: "Discovery Authenticate", primaryAction: .init { [weak self] _ in
        self?.discoveryAuthenticate()
    })

    var token: String?
    var discoveryToken: String?

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
        stackView.addArrangedSubview(discoveryStartButton)
        stackView.addArrangedSubview(discoveryAuthenticateButton)
    }

    func start() {
        guard let organizationId = organizationId else {
            presentAlertWithTitle(alertTitle: "No organization ID.")
            return
        }

        guard let url = URL(string: "B2BWorkbench://auth") else {
            return
        }

        let configuraiton = StytchB2BClient.OAuth.ThirdParty.WebAuthenticationConfiguration(
            loginRedirectUrl: url,
            signupRedirectUrl: url,
            organizationId: organizationId,
            customScopes: nil,
            providerParams: nil
        )

        Task {
            do {
                let (token, url) = try await StytchB2BClient.oauth.google.start(configuration: configuraiton)
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
                let response = try await StytchB2BClient.oauth.authenticate(
                    parameters: .init(
                        oauthToken: token,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "oauth authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "oauth authenticate error", object: error)
            }
        }
    }

    func discoveryStart() {
        guard let url = URL(string: "B2BWorkbench://auth") else {
            return
        }

        let configuraiton = StytchB2BClient.OAuth.ThirdParty.Discovery.WebAuthenticationConfiguration(
            discoveryRedirectUrl: url,
            customScopes: nil,
            providerParams: nil
        )

        Task {
            do {
                let (token, url) = try await StytchB2BClient.oauth.google.discovery.start(configuration: configuraiton)
                self.discoveryToken = token
                presentAlertAndLogMessage(description: "oauth discovery start success!", object: (token, url))
            } catch {
                presentAlertAndLogMessage(description: "oauth discovery start error", object: error)
            }
        }
    }

    func discoveryAuthenticate() {
        guard let token = discoveryToken else {
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.oauth.discovery.authenticate(parameters: .init(discoveryOauthToken: token))
                presentAlertAndLogMessage(description: "oauth discovery authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "oauth discovery authenticate error", object: error)
            }
        }
    }
}
