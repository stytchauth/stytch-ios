import StytchCore
import UIKit

final class MagicLinksViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()

    lazy var emailTextField: UITextField = .init(title: "Email", primaryAction: submitAction, keyboardType: .emailAddress)

    lazy var orgIdTextField: UITextField = .init(title: "Organization ID", primaryAction: submitAction)

    lazy var redirectUrlTextField: UITextField = .init(title: "Redirect URL", primaryAction: submitAction, keyboardType: .URL)

    lazy var sendButton: UIButton = .init(title: "Submit", primaryAction: submitAction)

    lazy var discoverySendButton: UIButton = .init(title: "Discover Send", primaryAction: .init { [weak self] _ in
        self?.submitDiscovery()
    })

    lazy var inviteSendButton: UIButton = .init(title: "Invite Send", primaryAction: .init { [weak self] _ in
        self?.submitInvite()
    })

    lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.submit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Email Magic Links"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(orgIdTextField)
        stackView.addArrangedSubview(redirectUrlTextField)
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(discoverySendButton)
        stackView.addArrangedSubview(inviteSendButton)

        emailTextField.text = UserDefaults.standard.string(forKey: Constants.emailDefaultsKey)
        orgIdTextField.text = UserDefaults.standard.string(forKey: Constants.orgIdDefaultsKey)
        redirectUrlTextField.text = UserDefaults.standard.string(forKey: Constants.redirectUrlDefaultsKey) ?? "b2bworkbench://auth"
    }

    func submit() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.map(URL.init(string:)) else { return }

        UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        UserDefaults.standard.set(orgId, forKey: Constants.orgIdDefaultsKey)
        UserDefaults.standard.set(redirectUrl?.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                let response = try await StytchB2BClient.magicLinks.email.loginOrSignup(
                    parameters: .init(
                        organizationId: .init(rawValue: orgId),
                        email: email,
                        loginRedirectUrl: redirectUrl,
                        signupRedirectUrl: redirectUrl
                    )
                )
                presentAlertAndLogMessage(description: "login or signup success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "login or signup error", object: error)
            }
        }
    }

    func submitDiscovery() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.map(URL.init(string:)) else { return }

        UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        UserDefaults.standard.set(orgId, forKey: Constants.orgIdDefaultsKey)
        UserDefaults.standard.set(redirectUrl?.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                let response = try await StytchB2BClient.magicLinks.email.discoverySend(
                    parameters: .init(
                        email: email,
                        redirectUrl: redirectUrl
                    )
                )
                presentAlertAndLogMessage(description: "discovery send success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "discovery send error", object: error)
            }
        }
    }

    func submitInvite() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return }
        guard let redirectUrl = redirectUrlTextField.text.map(URL.init(string:)) else { return }

        UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        UserDefaults.standard.set(orgId, forKey: Constants.orgIdDefaultsKey)
        UserDefaults.standard.set(redirectUrl?.absoluteURL, forKey: Constants.redirectUrlDefaultsKey)

        Task {
            do {
                let response = try await StytchB2BClient.magicLinks.email.inviteSend(
                    parameters: .init(
                        email: email
                    )
                )
                presentAlertAndLogMessage(description: "invite send success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "invite send error", object: error)
            }
        }
    }
}
