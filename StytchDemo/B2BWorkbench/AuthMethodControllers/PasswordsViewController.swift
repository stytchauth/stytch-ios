import StytchCore
import UIKit

final class PasswordsViewController: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.layoutMargins = Constants.insets
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private lazy var emailTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()

    private lazy var submitAction: UIAction = .init { [weak self] _ in
        self?.authenticate()
    }

    private lazy var orgIdTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Organization ID"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private lazy var redirectUrlTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Redirect URL"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
        return textField
    }()

    private lazy var passwordTextField: UITextField = {
        let textField: UITextField = .init(frame: .zero, primaryAction: submitAction)
        textField.borderStyle = .roundedRect
        textField.placeholder = "Password"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        return textField
    }()

    private lazy var authenticateButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Authenticate"
        return .init(configuration: configuration, primaryAction: submitAction)
    }()

    private lazy var checkStrengthButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Check Strength"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.checkStrength()
        })
    }()

    private lazy var secureToggle: UISwitch = {
        let toggle = UISwitch(frame: .zero, primaryAction: .init { [weak self] _ in
            guard let self else { return }
            self.passwordTextField.isSecureTextEntry = !self.secureToggle.isOn
        })
        return toggle
    }()

    private lazy var resetByEmailStartButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Reset by Email"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.resetByEmailStart()
        })
    }()

    private lazy var resetBySessionButton: UIButton = {
        var configuration: UIButton.Configuration = .borderedProminent()
        configuration.title = "Reset by Session"
        return .init(configuration: configuration, primaryAction: .init { [weak self] _ in
            self?.resetBySession()
        })
    }()

    private let passwordClient = StytchB2BClient.passwords

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
        stackView.addArrangedSubview(orgIdTextField)
        stackView.addArrangedSubview(redirectUrlTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(toggleStackView)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(checkStrengthButton)
        stackView.addArrangedSubview(resetByEmailStartButton)
        stackView.addArrangedSubview(resetBySessionButton)

        emailTextField.text = UserDefaults.standard.string(forKey: Constants.emailDefaultsKey)
        orgIdTextField.text = UserDefaults.standard.string(forKey: Constants.orgIdDefaultsKey)
        redirectUrlTextField.text = UserDefaults.standard.string(forKey: Constants.redirectUrlDefaultsKey) ?? "b2bworkbench://auth"

        if StytchB2BClient.sessions.memberSession == nil {
            resetBySessionButton.isHidden = true
        }
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

    private func authenticate() {
        guard let values = checkAndStoreTextFieldValues() else { return }

        Task {
            do {
                _ = try await passwordClient.authenticate(
                    parameters: .init(
                        organizationId: values.orgId,
                        email: values.email,
                        password: values.password
                    )
                )
                presentAlertWithTitle(alertTitle: "Authenticated!")
            } catch {
                print("authenticate error: \(error.errorInfo)")
            }
        }
    }

    private func checkStrength() {
        guard let password = passwordTextField.text, !password.isEmpty else { return }

        if let email = emailTextField.text, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        }

        Task {
            do {
                let response = try await passwordClient.strengthCheck(parameters: .init(email: emailTextField.text, password: password))
                presentAlertWithTitle(alertTitle: try encodeToJson(response))
            } catch {
                print("checkStrength error: \(error.errorInfo)")
            }
        }
    }

    private func resetByEmailStart() {
        guard let values = checkAndStoreTextFieldValues() else { return }
        Task {
            do {
                _ = try await self.passwordClient.resetByEmailStart(parameters: .init(organizationId: values.orgId, email: values.email, resetPasswordUrl: values.redirectUrl))
                presentAlertWithTitle(alertTitle: "Check your email!")
            } catch {
                print("resetByEmailStart error: \(error.errorInfo)")
            }
        }
    }

    private func resetBySession() {
        guard let values = checkAndStoreTextFieldValues() else { return }

        Task {
            do {
                _ = try await passwordClient.resetBySession(parameters: .init(organizationId: values.orgId, password: values.password))
            } catch {
                print("resetBySession error: \(error.errorInfo)")
            }
        }
    }

    private func resetByExistingPassword() {
        guard let values = checkAndStoreTextFieldValues() else { return }
        let resetPasswordWithNewPassword: (String) -> Void = { [weak self] newPassword in
            Task {
                do {
                    _ = try await self?.passwordClient.resetByExistingPassword(parameters: .init(organizationId: values.orgId, email: values.email, existingPassword: values.password, newPassword: newPassword))
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

    private func resetPassword(token: String, newPassword: String) {
        Task {
            do {
                _ = try await passwordClient.resetByEmail(parameters: .init(token: token, password: newPassword))
            } catch {
                print("resetPassword error: \(error.errorInfo)")
            }
        }
    }

    private func encodeToJson<T: Encodable>(_ object: T) throws -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try jsonEncoder.encode(object)
        return String(data: data, encoding: .utf8) ?? "Empty Data"
    }

    private func checkAndStoreTextFieldValues() -> (orgId: Organization.ID, password: String, email: String, redirectUrl: URL?)? {
        guard let orgId = orgIdTextField.text, !orgId.isEmpty else { return nil }

        let redirectUrl = redirectUrlTextField.text.flatMap(URL.init(string:))

        if let redirectUrl {
            UserDefaults.standard.set(redirectUrl.absoluteString, forKey: Constants.redirectUrlDefaultsKey)
        }

        if let email = emailTextField.text, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: Constants.emailDefaultsKey)
        }
        if let orgId = orgIdTextField.text, !orgId.isEmpty {
            UserDefaults.standard.set(orgId, forKey: Constants.orgIdDefaultsKey)
        }

        UserDefaults.standard.set(orgId, forKey: Constants.orgIdDefaultsKey)

        return (.init(rawValue: orgId), passwordTextField.text ?? "", emailTextField.text ?? "", redirectUrl)
    }
}
