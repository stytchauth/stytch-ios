import StytchCore
import UIKit

final class ConsumerMagicLinksViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var emailTextField: UITextField = .init(
        title: "Email",
        primaryAction: submitAction,
        keyboardType: .emailAddress
    )

    lazy var loginOrCreateButton: UIButton = .init(
        title: "Login or Create",
        primaryAction: .init { [weak self] _ in
            self?.submitLoginOrCreate()
        }
    )

    lazy var sendButton: UIButton = .init(
        title: "Send",
        primaryAction: .init { [weak self] _ in
            self?.submitSend()
        }
    )

    lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.submitLoginOrCreate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer Magic Links"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(loginOrCreateButton)
        stackView.addArrangedSubview(sendButton)

        emailTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)
        emailTextField.delegate = self
    }

    func submitLoginOrCreate() {
        guard let email = emailTextField.text, !email.isEmpty else { return }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchClient.magicLinks.email.loginOrCreate(
                    parameters: .init(
                        email: email,
                        loginMagicLinkUrl: redirectUrl,
                        signupMagicLinkUrl: redirectUrl,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "login or create success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "login or create error", object: error)
            }
        }
    }

    func submitSend() {
        guard let email = emailTextField.text, !email.isEmpty else { return }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchClient.magicLinks.email.send(
                    parameters: .init(
                        email: email,
                        loginMagicLinkUrl: redirectUrl,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "send success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "send error", object: error)
            }
        }
    }
}

extension ConsumerMagicLinksViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
