import StytchCore
import UIKit

final class PasswordsViewController: UIViewController {
    let stackView = UIStackView.stytchB2BStackView()

    lazy var emailTextField: UITextField = .init(title: "Email", primaryAction: submitAction, keyboardType: .emailAddress)

    lazy var redirectUrlTextField: UITextField = .init(title: "Redirect URL", primaryAction: submitAction, keyboardType: .URL)

    lazy var passwordTextField: UITextField = .init(title: "Password", primaryAction: submitAction, password: true)

    lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.authenticate()
    }

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: submitAction)

    lazy var checkStrengthButton: UIButton = .init(title: "Check Strength", primaryAction: .init { [weak self] _ in
        self?.checkStrength()
    })

    lazy var resetByEmailStartButton: UIButton = .init(title: "Reset by Email", primaryAction: .init { [weak self] _ in
        self?.resetByEmailStart()
    })

    lazy var resetBySessionButton: UIButton = .init(title: "Reset by Session", primaryAction: .init { [weak self] _ in
        self?.resetBySession()
    })

    lazy var secureToggle: UISwitch = {
        let toggle = UISwitch(frame: .zero, primaryAction: .init { [weak self] _ in
            guard let self else { return }
            self.passwordTextField.isSecureTextEntry = !self.secureToggle.isOn
        })
        return toggle
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Passwords"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        let toggleLabel = UILabel()
        toggleLabel.text = "Show password"
        let toggleStackView = UIStackView(arrangedSubviews: [secureToggle, toggleLabel])
        toggleStackView.spacing = 8

        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(redirectUrlTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(toggleStackView)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(checkStrengthButton)
        stackView.addArrangedSubview(resetByEmailStartButton)
        stackView.addArrangedSubview(resetBySessionButton)

        emailTextField.text = UserDefaults.standard.string(forKey: Constants.emailDefaultsKey)
        redirectUrlTextField.text = UserDefaults.standard.string(forKey: Constants.redirectUrlDefaultsKey) ?? "b2bworkbench://auth"

        if StytchB2BClient.sessions.memberSession == nil {
            resetBySessionButton.isHidden = true
        }

        emailTextField.delegate = self
        redirectUrlTextField.delegate = self
        passwordTextField.delegate = self
    }

    func initiatePasswordReset(token: String) {
        let controller = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
        controller.addTextField { $0.placeholder = "New password" }
        controller.addAction(.init(title: "Submit", style: .default) { [weak self, unowned controller] _ in
            guard let newPassword = controller.textFields?.first?.text, !newPassword.isEmpty else { return }
            self?.resetPassword(token: token, newPassword: newPassword)
        })
        controller.addAction(.init(title: "Cancel", style: .cancel))
        present(controller, animated: true)
    }

    func authenticate() {
        guard let values = checkAndStoreTextFieldValues() else {
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.authenticate(
                    parameters: .init(
                        organizationId: values.orgId,
                        email: values.email,
                        password: values.password
                    )
                )
                presentAlertAndLogMessage(description: "authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate error", object: error)
            }
        }
    }

    func checkStrength() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            return
        }

        if let email = emailTextField.text, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.strengthCheck(
                    parameters: .init(
                        email: emailTextField.text,
                        password: password
                    )
                )
                presentAlertAndLogMessage(description: "strength check success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "strength check error", object: error)
            }
        }
    }

    func resetByEmailStart() {
        guard let values = checkAndStoreTextFieldValues() else { return }
        Task {
            do {
                let response = try await StytchB2BClient.passwords.resetByEmailStart(
                    parameters: .init(
                        organizationId: values.orgId,
                        email: values.email,
                        resetPasswordUrl:
                        values.redirectUrl
                    )
                )
                presentAlertAndLogMessage(description: "reset by email success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by email error", object: error)
            }
        }
    }

    func resetBySession() {
        guard let values = checkAndStoreTextFieldValues() else {
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.resetBySession(
                    parameters: .init(
                        organizationId: values.orgId,
                        password: values.password
                    )
                )
                presentAlertAndLogMessage(description: "reset by session success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by session error", object: error)
            }
        }
    }

    func resetByExistingPassword() {
        guard let values = checkAndStoreTextFieldValues() else {
            return
        }

        let resetPasswordWithNewPassword: (String) -> Void = { [weak self] newPassword in
            Task {
                do {
                    let response = try await StytchB2BClient.passwords.resetByExistingPassword(
                        parameters: .init(
                            organizationId: values.orgId,
                            email: values.email,
                            existingPassword: values.password,
                            newPassword: newPassword
                        )
                    )
                    self?.presentAlertAndLogMessage(description: "reset by existing password success!", object: response)
                } catch {
                    self?.presentAlertAndLogMessage(description: "reset by existing password error", object: error)
                }
            }
        }

        let controller = UIAlertController(title: "Enter New Password", message: nil, preferredStyle: .alert)
        controller.addTextField { $0.placeholder = "New password" }
        controller.addAction(.init(title: "Cancel", style: .cancel))
        controller.addAction(.init(title: "OK", style: .default) { [unowned controller] _ in
            resetPasswordWithNewPassword(controller.textFields![0].text ?? "")
        })
    }

    func resetPassword(token: String, newPassword: String) {
        Task {
            do {
                let response = try await StytchB2BClient.passwords.resetByEmail(
                    parameters: .init(
                        token: token,
                        password: newPassword
                    )
                )
                presentAlertAndLogMessage(description: "reset password success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset password error", object: error)
            }
        }
    }

    func checkAndStoreTextFieldValues() -> (orgId: Organization.ID, password: String, email: String, redirectUrl: URL?)? {
        var orgizationID = ""
        if let orgID = organizationId {
            orgizationID = orgID
        }

        let redirectUrl = redirectUrlTextField.text.flatMap(URL.init(string:))

        if let redirectUrl {
            UserDefaults.standard.set(redirectUrl.absoluteString, forKey: Constants.redirectUrlDefaultsKey)
        }

        if let email = emailTextField.text, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        }

        return (.init(rawValue: orgizationID), passwordTextField.text ?? "", emailTextField.text ?? "", redirectUrl)
    }
}

extension PasswordsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
