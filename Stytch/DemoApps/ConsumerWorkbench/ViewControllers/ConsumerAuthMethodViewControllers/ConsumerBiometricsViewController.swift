import StytchCore
import UIKit
internal import LocalAuthentication

final class ConsumerBiometricsViewController: UIViewController {
    let stackView = UIStackView.stytchStackView()

    lazy var identifierTextField: UITextField = .init(
        title: "Identifier (email or label)",
        primaryAction: submitRegisterAction,
        keyboardType: .default
    )

    lazy var availabilityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Availability unknown"
        return label
    }()

    lazy var registerButton: UIButton = .init(
        title: "Register Biometrics",
        primaryAction: .init { [weak self] _ in
            self?.submitRegister()
        }
    )

    lazy var authenticateButton: UIButton = .init(
        title: "Authenticate",
        primaryAction: .init { [weak self] _ in
            self?.submitAuthenticate()
        }
    )

    lazy var removeButton: UIButton = .init(
        title: "Remove Registration",
        primaryAction: .init { [weak self] _ in
            self?.submitRemove()
        }
    )

    lazy var refreshButton: UIButton = .init(
        title: "Refresh Availability",
        primaryAction: .init { [weak self] _ in
            self?.refreshAvailability()
        }
    )

    lazy var submitRegisterAction: UIAction = .init { [weak self] _ in
        self?.submitRegister()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Consumer Biometrics"
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        stackView.addArrangedSubview(identifierTextField)
        stackView.addArrangedSubview(availabilityLabel)
        stackView.addArrangedSubview(registerButton)
        stackView.addArrangedSubview(authenticateButton)
        stackView.addArrangedSubview(removeButton)
        stackView.addArrangedSubview(refreshButton)

        identifierTextField.text = UserDefaults.standard.string(forKey: emailDefaultsKey)
        identifierTextField.delegate = self

        refreshAvailability()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshAvailability()
    }

    func refreshAvailability() {
        let availability = StytchClient.biometrics.availability
        let biometry = StytchClient.biometrics.biometryType

        switch availability {
        case let .systemUnavailable(code):
            availabilityLabel.text = "System unavailable. Code: \(code?.rawValue.description ?? "none")"
            registerButton.isEnabled = false
            authenticateButton.isEnabled = false
            removeButton.isEnabled = false

        case .availableNoRegistration:
            availabilityLabel.text = "Available, no registration. Biometry: \(biometry == .faceID ? "FaceID" : biometry == .touchID ? "TouchID" : "None")"
            registerButton.isEnabled = true
            authenticateButton.isEnabled = false
            removeButton.isEnabled = false

        case .availableRegistered:
            availabilityLabel.text = "Available, already registered. Biometry: \(biometry == .faceID ? "FaceID" : biometry == .touchID ? "TouchID" : "None")"
            registerButton.isEnabled = false
            authenticateButton.isEnabled = true
            removeButton.isEnabled = true
        }
    }

    func submitRegister() {
        guard let identifier = identifierTextField.text, !identifier.isEmpty else { return }
        UserDefaults.standard.set(identifier, forKey: emailDefaultsKey)

        Task {
            do {
                let response = try await StytchClient.biometrics.register(
                    parameters: .init(
                        identifier: identifier,
                        accessPolicy: .deviceOwnerAuthenticationWithBiometrics,
                        sessionDurationMinutes: StytchClient.defaultSessionDuration,
                        promptStrings: .defaultPromptStrings
                    )
                )
                presentAlertAndLogMessage(description: "register success", object: response)
                refreshAvailability()
            } catch {
                presentAlertAndLogMessage(description: "register error", object: error)
                refreshAvailability()
            }
        }
    }

    func submitAuthenticate() {
        Task {
            do {
                let response = try await StytchClient.biometrics.authenticate(
                    parameters: .init(
                        sessionDurationMinutes: StytchClient.defaultSessionDuration,
                        promptStrings: .defaultPromptStrings
                    )
                )
                presentAlertAndLogMessage(description: "authenticate success", object: response)
                refreshAvailability()
            } catch {
                presentAlertAndLogMessage(description: "authenticate error", object: error)
                refreshAvailability()
            }
        }
    }

    func submitRemove() {
        Task {
            do {
                try await StytchClient.biometrics.removeRegistration()
                presentAlertAndLogMessage(description: "remove success", object: "Removed local and server registration")
                refreshAvailability()
            } catch {
                presentAlertAndLogMessage(description: "remove error", object: error)
                refreshAvailability()
            }
        }
    }
}

extension ConsumerBiometricsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
