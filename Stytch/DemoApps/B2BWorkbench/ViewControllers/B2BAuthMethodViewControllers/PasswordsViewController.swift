import StytchCore
import UIKit

let discoveryRedirectUrlDefaultsKey = "StytchDiscoveryRedirectUrl"

final class PasswordsViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var emailTextField: UITextField = .init(title: "Email", primaryAction: submitAction, keyboardType: .emailAddress)

    lazy var discoveryRedirectUrlTextField: UITextField = .init(title: "Discovery Redirect URL", primaryAction: submitAction, keyboardType: .URL)

    lazy var passwordTextField: UITextField = .init(title: "Password", primaryAction: submitAction, password: true)

    lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.authenticate()
    }

    lazy var authenticateButton: UIButton = .init(title: "Authenticate", primaryAction: submitAction)

    lazy var checkStrengthButton: UIButton = .init(title: "Check Strength", primaryAction: .init { [weak self] _ in
        self?.checkStrength()
    })

    lazy var resetByEmailStartButton: UIButton = .init(title: "Reset by Email Start", primaryAction: .init { [weak self] _ in
        self?.resetByEmailStart()
    })

    lazy var resetBySessionButton: UIButton = .init(title: "Reset by Session", primaryAction: .init { [weak self] _ in
        self?.resetBySession()
    })

    lazy var resetByExistingPasswordButton: UIButton = .init(title: "Reset by Existing Password", primaryAction: .init { [weak self] _ in
        self?.resetByExistingPassword()
    })

    lazy var discoveryAuthenticateButton: UIButton = .init(title: "Discovery Authenticate", primaryAction: .init { [weak self] _ in
        self?.discoveryAuthenticate()
    })

    lazy var discoveryResetByEmailStartButton: UIButton = .init(title: "Discovery Reset by Email Start", primaryAction: .init { [weak self] _ in
        self?.discoveryResetByEmailStart()
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
        stackView.addArrangedSubview(discoveryRedirectUrlTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(toggleStackView)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(checkStrengthButton)
        stackView.addArrangedSubview(resetByEmailStartButton)
        stackView.addArrangedSubview(resetBySessionButton)
        stackView.addArrangedSubview(resetByExistingPasswordButton)
        stackView.addArrangedSubview(discoveryAuthenticateButton)
        stackView.addArrangedSubview(discoveryResetByEmailStartButton)

        emailTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)
        discoveryRedirectUrlTextField.text = UserDefaults.standard.string(forKey: discoveryRedirectUrlDefaultsKey) ?? "b2bworkbench://auth"

        if StytchB2BClient.sessions.memberSession == nil {
            resetBySessionButton.isHidden = true
        }

        emailTextField.delegate = self
        discoveryRedirectUrlTextField.delegate = self
        passwordTextField.delegate = self
    }

    func authenticate() {
        guard let values = checkAndStoreTextFieldValues(),
              values.password.isEmpty == false,
              values.email.isEmpty == false
        else {
            presentAlertWithTitle(alertTitle: "Missing email, password or redirect url. Check missing fields and try again.")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.authenticate(
                    parameters: .init(
                        organizationId: values.orgId,
                        emailAddress: values.email,
                        password: values.password,
                        locale: .en
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
            UserDefaults.standard.set(email, forKey: emailDefaultsKey)
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.strengthCheck(
                    parameters: .init(
                        emailAddress: emailTextField.text,
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
        guard let values = checkAndStoreTextFieldValues() else {
            presentAlertWithTitle(alertTitle: "Missing email, password or redirect url. Check missing fields and try again.")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.resetByEmailStart(
                    parameters: .init(
                        organizationId: values.orgId,
                        emailAddress: values.email,
                        resetPasswordRedirectUrl: values.redirectUrl,
                        resetPasswordTemplateId: nil,
                        verifyEmailTemplateId: nil,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "reset by email success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by email error", object: error)
            }
        }
    }

    func resetByEmail(passwordResetToken: String, newPassword: String) {
        Task {
            do {
                let response = try await StytchB2BClient.passwords.resetByEmail(
                    parameters: .init(
                        passwordResetToken: passwordResetToken,
                        password: newPassword,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "reset password success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset password error", object: error)
            }
        }
    }

    func resetBySession() {
        guard let values = checkAndStoreTextFieldValues() else {
            presentAlertWithTitle(alertTitle: "Missing email, password or redirect url. Check missing fields and try again.")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.resetBySession(
                    parameters: .init(
                        organizationId: values.orgId,
                        password: values.password,
                        locale: .en
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
            presentAlertWithTitle(alertTitle: "Missing email, password or redirect url. Check missing fields and try again.")
            return
        }

        Task {
            do {
                guard let newPassword = try await presentTextFieldAlertWithTitle(alertTitle: "Enter New Password") else {
                    throw TextFieldAlertError.emptyString
                }

                let response = try await StytchB2BClient.passwords.resetByExistingPassword(
                    parameters: .init(
                        organizationId: values.orgId,
                        emailAddress: values.email,
                        existingPassword: values.password,
                        newPassword: newPassword,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "reset by existing password success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "reset by existing password error", object: error)
            }
        }
    }

    func discoveryAuthenticate() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
        else {
            presentAlertWithTitle(alertTitle: "Missing email or password. Check the fields and try again.")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.discovery.authenticate(
                    parameters: .init(
                        emailAddress: email,
                        password: password
                    )
                )
                presentAlertAndLogMessage(description: "discovery authenticate success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "discovery authenticate error", object: error)
            }
        }
    }

    func discoveryResetByEmailStart() {
        guard let email = emailTextField.text, !email.isEmpty,
              let redirectUrl = discoveryRedirectUrlTextField.text.flatMap(URL.init(string:))
        else {
            presentAlertWithTitle(alertTitle: "Missing email or redirect URL. Check the fields and try again.")
            return
        }

        Task {
            do {
                let response = try await StytchB2BClient.passwords.discovery.resetByEmailStart(
                    parameters: .init(
                        emailAddress: email,
                        discoveryRedirectUrl: redirectUrl,
                        resetPasswordRedirectUrl: redirectUrl,
                        resetPasswordTemplateId: nil,
                        verifyEmailTemplateId: nil,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "discovery reset by email success - check your email!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "discovery reset by email error", object: error)
            }
        }
    }

    func discoveryResetByEmail(token: String, newPassword: String) {
        Task {
            do {
                let response = try await StytchB2BClient.passwords.discovery.resetByEmail(
                    parameters: .init(
                        passwordResetToken: token,
                        password: newPassword,
                        locale: .en
                    )
                )
                presentAlertAndLogMessage(description: "discovery reset password success!", object: response)
            } catch {
                presentAlertAndLogMessage(description: "discovery reset password error", object: error)
            }
        }
    }

    func resetPassword(token: String, passwordDiscovery: Bool) {
        Task {
            do {
                guard let newPassword = try await presentTextFieldAlertWithTitle(alertTitle: "Reset Password") else {
                    throw TextFieldAlertError.emptyString
                }

                if passwordDiscovery == true {
                    discoveryResetByEmail(token: token, newPassword: newPassword)
                } else {
                    resetByEmail(passwordResetToken: token, newPassword: newPassword)
                }
            } catch {
                presentAlertAndLogMessage(description: "reset password error", object: error)
            }
        }
    }

    func checkAndStoreTextFieldValues() -> (orgId: Organization.ID, password: String, email: String, redirectUrl: URL?, discoveryRedirectUrl: URL?)? {
        var orgizationID = ""
        if let orgID = organizationId {
            orgizationID = orgID
        }

        let discoveryRedirectUrl = discoveryRedirectUrlTextField.text.flatMap(URL.init(string:))
        if let discoveryRedirectUrl {
            UserDefaults.standard.set(discoveryRedirectUrl.absoluteString, forKey: discoveryRedirectUrlDefaultsKey)
        }

        if let email = emailTextField.text, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: emailDefaultsKey)
        }

        return (.init(rawValue: orgizationID), passwordTextField.text ?? "", emailTextField.text ?? "", redirectUrl, discoveryRedirectUrl)
    }
}

extension PasswordsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
