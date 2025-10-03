import StytchCore
import UIKit

final class MagicLinksViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var emailTextField: UITextField = .init(title: "Email", primaryAction: submitAction, keyboardType: .emailAddress)

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
        stackView.addArrangedSubview(sendButton)
        stackView.addArrangedSubview(discoverySendButton)
        stackView.addArrangedSubview(inviteSendButton)

        emailTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)

        emailTextField.delegate = self
    }

    func submit() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let orgId = organizationId else { return }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchB2BClient.magicLinks.email.loginOrSignup(
                    parameters: .init(
                        organizationId: .init(rawValue: orgId),
                        emailAddress: email,
                        loginRedirectUrl: redirectUrl,
                        signupRedirectUrl: redirectUrl,
                        locale: .en
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

        guard organizationId != nil else {
            return
        }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchB2BClient.magicLinks.email.discoverySend(
                    parameters: .init(
                        emailAddress: email,
                        discoveryRedirectUrl: redirectUrl,
                        locale: .en
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

        guard organizationId != nil else {
            return
        }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchB2BClient.magicLinks.email.inviteSend(
                    parameters: .init(
                        emailAddress: email,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "invite send success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "invite send error", object: error)
            }
        }
    }
}

extension MagicLinksViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
