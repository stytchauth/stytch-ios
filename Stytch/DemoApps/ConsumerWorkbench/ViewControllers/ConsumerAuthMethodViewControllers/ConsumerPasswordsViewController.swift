import StytchCore
import UIKit

final class ConsumerPasswordsViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    // Inputs
    lazy var emailTextField: UITextField = .init(
        title: "Email",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        keyboardType: .emailAddress
    )

    lazy var passwordTextField: UITextField = .init(
        title: "Password",
        primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) },
        password: true
    )

    // Buttons
    lazy var authenticateButton: UIButton = .init(
        title: "Authenticate",
        primaryAction: .init { [weak self] _ in self?.authenticate() }
    )

    lazy var checkStrengthButton: UIButton = .init(
        title: "Check Strength",
        primaryAction: .init { [weak self] _ in self?.checkStrength() }
    )

    lazy var resetByEmailStartButton: UIButton = .init(
        title: "Reset by Email Start",
        primaryAction: .init { [weak self] _ in self?.resetByEmailStart() }
    )

    lazy var resetBySessionButton: UIButton = .init(
        title: "Reset by Session",
        primaryAction: .init { [weak self] _ in self?.resetBySession() }
    )

    lazy var resetByExistingPasswordButton: UIButton = .init(
        title: "Reset by Existing Password",
        primaryAction: .init { [weak self] _ in self?.resetByExistingPassword() }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer Passwords"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(checkStrengthButton)
        stackView.addArrangedSubview(UIView.spacer(height: 12))
        stackView.addArrangedSubview(resetByEmailStartButton)
        stackView.addArrangedSubview(resetBySessionButton)
        stackView.addArrangedSubview(resetByExistingPasswordButton)

        emailTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)

        emailTextField.delegate = self
        passwordTextField.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditingTap() {
        view.endEditing(true)
    }

    // Actions

    func authenticate() {
        guard
            let email = emailTextField.text, email.isEmpty == false,
            let password = passwordTextField.text, password.isEmpty == false
        else {
            presentAlertWithTitle(alertTitle: "Missing email or password")
            return
        }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchClient.passwords.authenticate(
                    parameters: .init(email: email, password: password, sessionDurationMinutes: StytchClient.defaultSessionDuration)
                )
                presentAlertAndLogMessage(description: "authenticate success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "authenticate error", object: error)
            }
        }
    }

    func checkStrength() {
        guard let password = passwordTextField.text, password.isEmpty == false else {
            presentAlertWithTitle(alertTitle: "Enter a password to check strength")
            return
        }

        let email = emailTextField.text
        if let emailUnwrapped = email, emailUnwrapped.isEmpty == false {
            UserDefaults.standard.set(emailUnwrapped, forKey: emailDefaultsKey)
        }

        Task {
            do {
                let response = try await StytchClient.passwords.strengthCheck(
                    parameters: .init(email: email, password: password)
                )
                presentAlertAndLogMessage(description: "strength check success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "strength check error", object: error)
            }
        }
    }

    func resetByEmailStart() {
        guard let email = emailTextField.text, email.isEmpty == false else {
            presentAlertWithTitle(alertTitle: "Missing email")
            return
        }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchClient.passwords.resetByEmailStart(
                    parameters: .init(
                        email: email,
                        loginRedirectUrl: redirectUrl,
                        resetPasswordRedirectUrl: redirectUrl,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "reset by email start success, check your email", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by email start error", object: error)
            }
        }
    }

    func resetBySession() {
        guard let newPassword = passwordTextField.text, newPassword.isEmpty == false else {
            presentAlertWithTitle(alertTitle: "Enter a new password in the password field")
            return
        }

        Task {
            do {
                let response = try await StytchClient.passwords.resetBySession(
                    parameters: .init(password: newPassword, sessionDurationMinutes: StytchClient.defaultSessionDuration)
                )
                presentAlertAndLogMessage(description: "reset by session success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by session error", object: error)
            }
        }
    }

    func resetByExistingPassword() {
        guard
            let email = emailTextField.text, email.isEmpty == false,
            let existing = passwordTextField.text, existing.isEmpty == false
        else {
            presentAlertWithTitle(alertTitle: "Missing email or existing password")
            return
        }

        UserDefaults.standard.set(email, forKey: emailDefaultsKey)

        Task {
            do {
                guard let newPassword = try await presentTextFieldAlertWithTitle(alertTitle: "Enter New Password") else {
                    throw TextFieldAlertError.emptyString
                }

                let response = try await StytchClient.passwords.resetByExistingPassword(
                    parameters: .init(
                        emailAddress: email,
                        existingPassword: existing,
                        newPassword: newPassword,
                        sessionDurationMinutes: StytchClient.defaultSessionDuration
                    )
                )
                presentAlertAndLogMessage(description: "reset by existing password success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by existing password error", object: error)
            }
        }
    }

    func resetPassword(token: String) {
        Task {
            do {
                guard let newPassword = try await presentTextFieldAlertWithTitle(alertTitle: "Reset Password") else {
                    throw TextFieldAlertError.emptyString
                }

                resetByEmail(passwordResetToken: token, newPassword: newPassword)
            } catch {
                presentAlertAndLogMessage(description: "reset password error", object: error)
            }
        }
    }

    func resetByEmail(passwordResetToken: String, newPassword: String) {
        Task {
            do {
                let response = try await StytchClient.passwords.resetByEmail(
                    parameters: .init(token: passwordResetToken, password: newPassword)
                )
                presentAlertAndLogMessage(description: "reset by email complete success", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by email complete error", object: error)
            }
        }
    }
}

extension ConsumerPasswordsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
